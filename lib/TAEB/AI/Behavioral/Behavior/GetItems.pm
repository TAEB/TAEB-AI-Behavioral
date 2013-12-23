package TAEB::AI::Behavioral::Behavior::GetItems;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';
use TAEB::Util 'any';
use TAEB::AI::Behavioral::Util;

sub prepare {
    my $self = shift;

    # picking up items while blind tends to work very badly
    # e.g. "j - a wand"
    return if TAEB->is_blind;

    return if TAEB::Action::Pickup->is_impossible;

    my @items = TAEB->current_tile->items;
    my @want = grep { TAEB->ai->want_item($_) } @items;
    if (@want) {
        TAEB->log->behavior("TAEB wants items! @want");
        $self->currently("Picking up items");

        # If there is one item on this square, we don't get the pickup menu,
        # so this has to be special.  Sigh.

        my $count = TAEB->ai->want_item($want[0]);

        @items == 1 && $count ne 'all' ? $self->do('pickup', count => $count)
                                       : $self->do('pickup');
        $self->urgency('normal');
        return;
    }

    if (my $container = TAEB->current_tile->container) {
        my @in_container = grep { TAEB->ai->want_item($_) }
                                @{ $container->contents };
        if (@in_container || !$container->contents_known) {
            TAEB->log->behavior("TAEB wants container items! @in_container");

            if ($container->locked) {
                if (my $locktool = $self->locktool) {
                    $self->currently("Unlocking a container");
                    $self->do('unlock',
                        implement => $locktool,
                        direction => '.'
                    );
                    $self->urgency('normal');
                    return;
                }
                else {
                    TAEB->log->behavior("but can't get to them...");
                }
            }
            else {
                $self->currently("Looting items from a container");
                $self->do('loot', container => $container);
                $self->urgency('normal');
                return;
            }
        }
    }

    return unless TAEB->current_level->has_type('unknown_items')
               || any {
                     TAEB->ai->want_item($_)
                  || ($_->isa('NetHack::Item::Tool::Container')
                   && !$_->contents_known)
                  } TAEB->current_level->items;

    my $path = TAEB::World::Path->first_match(sub {
        my $tile = shift;

        return if $tile->in_vault;

        if ($tile->in_shop || $tile->in_temple) {
            #this lets taeb go shopping once and keeps from
            #oscillating due to shk leaving LOS on items
            return 0 if $tile->stepped_on || $tile->glyph eq '@';

            # unresolved debt, don't compound it
            return 0 if TAEB->debt > 0;
        }

        # zoos tend to have sleeping peacefuls
        return 0 if $tile->has_monster && $tile->in_zoo;

        return 1 if $tile->has_unknown_items;
        return 1 if any { TAEB->ai->want_item($_) } $tile->items;

        my $container = $tile->container;
        if ($container
         && (!$container->locked || $self->locktool)) {
            return 1 if !$container->contents_known;
            return 1 if any { TAEB->ai->want_item($_) } @{ $container->contents };
        }

        return;
    });

    $self->if_path($path => "Heading towards an item");
}

use constant max_urgency => 'normal';

__PACKAGE__->meta->make_immutable;

1;

