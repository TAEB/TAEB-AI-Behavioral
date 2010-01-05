package TAEB::AI::Behavioral::Behavior::Defend;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';
use Scalar::Defer 'lazy';

sub prepare {
    my $self = shift;

    if (TAEB->hp * 2 <= TAEB->maxhp) {
        my $can_engrave = TAEB::Action::Engrave->is_advisable;
        my $elbereths   = lazy { TAEB->elbereth_count };
        my $burned      = lazy {
            $elbereths >= 1 && TAEB->current_tile->engraving_type eq 'burned'
        };

        my ($adjacent_ignoring, $adjacent_respecting) = (0, 0);
        TAEB->each_adjacent(sub {
            my $monster = shift->monster or return;
            return unless $monster->is_enemy;

            $monster->respects_elbereth
                ? ++$adjacent_respecting
                : ++$adjacent_ignoring
        });

        # if at least 3 adjacent monsters obey Elbereth, and we can burn an
        # Elbereth but haven't, burn one (so as not to get surrounded).
        if ($adjacent_respecting >= 3 && $can_engrave && !$burned &&
            (TAEB->has_item('wand of fire') ||
             TAEB->has_item('wand of lightning'))) {
            $self->write_elbereth(add_engraving => 0,
                                  method => 'best');
            $self->currently("burning Elbereth because I'm surrounded");
            $self->urgency('normal');
            return;
        }

        # if there's an adjacent monster that ignores Elbereth, then we only
        # write Elbereth if there's no Elbereth on the ground AND there's an
        # adjacent Elbereth-respecting monster. we don't rest on Elbereth
        if ($adjacent_ignoring) {
            if ($can_engrave && $adjacent_respecting && $elbereths == 0) {
                $self->write_elbereth(add_engraving => $elbereths ? 1 : 0);
                $self->urgency('normal');
            }
            return;
        }

        # otherwise, we write Elbereth if we can, there's not already an
        # excessive amount of them, and we don't have a permanent E
        if ($can_engrave && $elbereths < 3 && !$burned) {
            $self->write_elbereth(add_engraving => $elbereths ? 1 : 0);
            $self->urgency('normal');
            return;
        }

        # finally, we have an Elbereth under us, so we rest up to heal
        if ($elbereths) {
            $self->urgency(TAEB->hp * 4 <= TAEB->maxhp ? 'normal'
                                                       : 'unimportant');
            if (TAEB->current_tile->type eq 'stairsup' && TAEB->z > 1) {
                $self->currently("Fleeing upstairs to rest.");
                $self->do('ascend');
                return;
            }
            $self->currently("Resting on an Elbereth tile.");
            $self->do('search', iterations => 5);
            return;
        }
    }
    if (TAEB->hp * 4 <= TAEB->maxhp * 3 && !TAEB->current_level->has_enemies) {
        $self->currently("Resting up to gain some hp");
        $self->do('search');
        $self->urgency('unimportant');
        return;
    }
    if ((TAEB->power * 5 <= TAEB->maxpower || TAEB->power < 5) &&
            !TAEB->current_level->has_enemies &&
            TAEB->role eq 'Wiz') { #XXX should be "primary spellcaster"
        $self->currently("Resting up to gain some power");
        $self->do('search');
        # This needs to be high fallback so that we eat first.  Perhaps
        # hp resting should too?
        $self->urgency('fallback');
        return;
    }
}

use constant max_urgency => 'normal';

sub pickup {
    my $self = shift;
    my $item = shift;
    return $item->match(identity => qr/wand of (?:fire|lightning|digging)/,
                        charges  => sub { !defined $_[0] || $_[0] > 0 })
        || $item->match(identity => ['Magicbane', 'magic marker']);
}

sub drop {
    my $self = shift;
    my $item = shift;
    return 1 if $item->match(identity => qr/wand of (?:fire|lightning|digging)/,
                             charges  => 0);
    return;
}

__PACKAGE__->meta->make_immutable;

1;

