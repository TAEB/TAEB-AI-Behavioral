package TAEB::AI::Behavioral::Behavior::Equip;
use TAEB::OO;
use TAEB::Spoilers::Combat;
extends 'TAEB::AI::Behavioral::Behavior';

sub _rate_armor {
    my $self = shift;
    my $item = shift;

    return 0 if !$item;

    return ($item->ac || 0) + ($item->enchantment || 0);
}

sub prepare {
    my $self = shift;

    return if $self->prepare_armor;
}

sub prepare_armor {
    my $self = shift;

    for my $slot (TAEB->equipment->armor_slots) {
        my $incumbent       = TAEB->equipment->$slot;
        my $incumbent_score = $self->_rate_armor($incumbent);

        # Can't remove it :(
        next if $incumbent && $incumbent->is_cursed;

        my @candidates = TAEB->inventory->find(
            type    => 'armor',
            subtype => $slot,
        );

        my ($max_score, $item) = (0, undef);
        for my $candidate (@candidates) {
            my $rating = $self->_rate_armor($candidate);

            ($max_score, $item) = ($rating, $candidate)
                if $rating > $max_score;
        }

        next if $max_score <= $incumbent_score;

        if ($incumbent) {
            $self->do(unwear => item => $incumbent);
            $self->currently("Removing $incumbent to wear $candidate.");
        }
        else {
            $self->do(wear => item => $candidate);
            $self->currently("Putting on $candidate.");
        }

        $self->urgency('normal');

        return $candidate;
    }

    return 0;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->type eq 'armor';

    my $slot = $item->subtype;
    my $incumbent = TAEB->equipment->$slot;

    return $self->_rate_armor($item) > $self->_rate_armor($incumbent);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

