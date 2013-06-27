#!/usr/bin/env perl
package TAEB::AI::Behavior::Heal;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub use_potions {
    map { "potion of $_" }
    'healing', 'extra healing', 'full healing'
}

sub prepare {
    my $self = shift;

    if (TAEB->hp * 2 <= TAEB->maxhp) {
        my $spell = TAEB->find_castable("healing")
                 || TAEB->find_castable("extra healing");
        if ($spell) {
            $self->do(cast => spell => $spell, direction => ".");
            $self->currently("Casting heal at myself.");
            $self->urgency('important');
            return;
        }

        # we've probably been writing Elbereth a bunch, so find a healing potion
        if (TAEB->hp * 3 < TAEB->maxhp) {
            my $potion = TAEB->find_item([$self->use_potions]);
            if ($potion) {
                $self->do(quaff => from => $potion);
                $self->currently("Quaffing a $potion");
                $self->urgency('important');
                return;
            }
        }

        if (TAEB->hp * 7 < TAEB->maxhp || TAEB->hp < 6) {
            if (!TAEB->is_polymorphed && TAEB->can_pray) {
                $self->do('pray');
                $self->currently("Praying for healing");
                $self->urgency('critical');
                return;
            }
        }
    }

    # now casual healing
    if (TAEB->hp * 3 / 2 <= TAEB->maxhp) {
        if (TAEB->power >= 20) {
            if (my $spell = TAEB->find_castable("healing")) {
                $self->do(cast => spell => $spell, direction => ".");
                $self->currently("Casting heal at myself.");
                $self->urgency('unimportant');
                return;
            }
        }
    }
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return $item->match(identity => [$self->use_potions]);
}

sub urgencies {
    return {
       critical    => "praying for health",
       important   => "healing because of low health",
       unimportant => "casual healing",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

