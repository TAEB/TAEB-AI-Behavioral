package TAEB::AI::Behavioral::Behavior::GetItems;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';
use List::MoreUtils 'any';

sub prepare {
    my $self = shift;

    # picking up items while blind tends to work very badly
    # e.g. "j - a wand"
    return if TAEB->is_blind;

    my @items = TAEB->current_tile->items;
    my @want = grep { TAEB->want_item($_) } @items;
    if (@want) {
        TAEB->log->behavior("TAEB wants items! @want");
        $self->currently("Picking up items");

        # If there is one item on this square, we don't get the pickup menu,
        # so this has to be special.  Sigh.

        my $count = TAEB->want_item($want[0]);

        $count = (@items == 1 && ref $count) ? $$count : undef;

        $self->do("pickup", count => $count);
        $self->urgency('normal');
        return;
    }

    return unless TAEB->current_level->has_type('interesting')
               || any { TAEB->want_item($_) } TAEB->current_level->items;

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

        return 1 if $tile->is_interesting;
        return any { TAEB->want_item($_) } $tile->items;
    }, why => "GetItems");

    $self->if_path($path => "Heading towards an item");
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

