package TAEB::AI::Behavioral::Behavior::Heal;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub use_spells { ('extra healing', 'healing') }

sub use_potions {
    map { "potion of $_" }
    'healing', 'extra healing', 'full healing'
}

sub prepare {
    my $self = shift;

    if (TAEB->hp * 2 <= TAEB->maxhp) {
        for ($self->use_spells) {
            my $spell = TAEB->find_castable($_);
            next unless $spell;
            $self->currently("Casting heal at myself.");
            $self->do(cast => spell => $spell, direction => ".");
            $self->urgency('important');
        }

        # we've probably been writing Elbereth a bunch, so find a healing potion
        if (TAEB->hp * 3 < TAEB->maxhp) {
            my $potion = TAEB->has_item([$self->use_potions]);
            if ($potion) {
                $self->do(quaff => from => $potion);
                $self->currently("Quaffing a $potion");
                $self->urgency('important');
                return;
            }
        }

        if (TAEB->in_pray_heal_range) {
            if (!TAEB->is_polymorphed && TAEB::Action::Pray->is_advisable) {
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

use constant max_urgency => 'critical';

sub pickup {
    my $self = shift;
    my $item = shift;

    return $item->match(identity => [$self->use_potions]);
}

__PACKAGE__->meta->make_immutable;

1;

