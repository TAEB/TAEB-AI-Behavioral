#!/usr/bin/perl
package TAEB::AI::Behavior::Equip;
use TAEB::OO;
use TAEB::Spoilers::Combat;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;
    my $current_weapon = TAEB->inventory->wielded || '-';
    my $current_avgdam = TAEB::Spoilers::Combat::damage($current_weapon);

    my ($best_weapon, $best_avgdam) = ($current_weapon, $current_avgdam);
    TAEB->inventory->each(sub {
        return if $_->match(buc => ['cursed', undef]);
        my $avgdam = TAEB::Spoilers::Combat::damage($_);
        if ($avgdam > $best_avgdam) {
            $best_avgdam = $avgdam;
            $best_weapon = $_;
        }
    }, class => 'weapon');
    # XXX: need to handle switching from barehanded to weapon and back
    if (blessed $best_weapon) {
        return 0 if $best_weapon->match(slot => $current_weapon->slot);
    }
    else {
        return 0 if $best_weapon eq $current_weapon;
    }

    $self->do(wield => weapon => $best_weapon);
    $self->currently("Equipping a better weapon");
    return 100;
}

sub urgencies {
    return {
        100 => "equipping a better weapon",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

