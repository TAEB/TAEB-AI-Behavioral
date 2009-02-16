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
        my $incumbent        = TAEB->equipment->$slot;
        my $incumbent_rating = $self->_rate_armor($incumbent);

        my @candidates = TAEB->inventory->find(
            type    => 'armor',
            subtype => $slot,
        );

        for my $candidate (@candidates) {
            my $rating = $self->_rate_armor($candidate);
            next if $rating <= $incumbent_rating;

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
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

