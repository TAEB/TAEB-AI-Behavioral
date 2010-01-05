package TAEB::AI::Behavioral::Behavior::Shop;
use Moose;
use TAEB::OO;
use TAEB::Util 'any';
extends 'TAEB::AI::Behavioral::Behavior';

# for now, we just drop unpaid items

sub prepare {
    my $self = shift;

    if (TAEB->debt > 0) {
        my @cart = grep { $_->cost } TAEB->inventory;

        if (any { $_->cost <= TAEB->gold } @cart) {
            $self->currently("Paying off our " . TAEB->debt . " debt");
            $self->do(pay => item => 'any');
            $self->urgency('unimportant');
            return;
        }

        # every item in our cart is greater than our current gold :(
        if (@cart) {
            $self->currently("Dropping items since I can't afford them");
            $self->do(drop => items => \@cart);
            $self->urgency('unimportant');
            return;
        }
        #try to pay for used item/damages debt
        if (!@cart && TAEB->debt > 0) {
            $self->currently("Paying off our " . TAEB->debt . " debt");
            $self->do(pay => item => 'any');
            $self->urgency('unimportant');
            return;
        }
    }
}

use constant max_urgency => 'unimportant';

sub drop {
    my $self = shift;
    my $item = shift;

    # not in a shop? then don't care
    return unless TAEB->current_tile->in_shop;

    # if there's an adjacent shopkeeper, then we want to drop pick-axes and
    # mattocks
    if ($item->match(identity => qr/pick-axe|dwarvish mattock/)) {
        return 1 if TAEB->any_adjacent(sub {
            my $tile = shift;
            return $tile->has_monster && $tile->monster->is_shk;
        });
    }

    # drop items we can't afford
    if ($item->cost > TAEB->gold) {
        TAEB->log->behavior("Yes, I want to drop $item because I can't pay for it");
        return 1;
    }

    return; #don't care
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return if TAEB->current_tile->in_vault || !TAEB->current_tile->in_shop;

    if ($item->cost > TAEB->gold) {
        TAEB->log->behavior("Item " . $item . "costs too much to pickup");
        return 0;
    }
    if ($item->match(appearance => 'gold piece')) {
        return 1;
    }
}

__PACKAGE__->meta->make_immutable;

1;

