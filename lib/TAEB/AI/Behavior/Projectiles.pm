#!/usr/bin/env perl
package TAEB::AI::Behavior::Projectiles;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

my @projectiles = (
    qr/\bdagger\b/,
    qr/\bspear\b/,
    qr/\bshuriken\b/,
    qr/\bboomerang\b/,
    qr/\bdart\b/,
);

sub prepare {
    my $self = shift;

    return 0 unless TAEB->current_level->has_enemies;

    # do we have a projectile to throw?
    my $projectile;
    for (@projectiles) {
        $projectile = TAEB->find_item($_) and last;
    }
    return 0 unless defined $projectile;

    my ($direction, $distance, $tile) = TAEB->current_level->radiate(
        sub { shift->has_enemy },
        max     => $projectile->throw_range,
        stopper => sub { shift->has_friendly },
    );

    # no monster found
    return 0 if !$direction;

    return if $tile->in_shop;

    $self->do(throw =>
        item        => $projectile,
        direction   => $direction,
        target_tile => $tile,
    );
    $self->currently("Throwing a projectile at a monster.");
    return 100;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    $item->match(identity => qr/\b(?:dagger|dart|shuriken|boomerang|spear)\b/,
                 not_buc => 'cursed');
}

sub urgencies {
    return {
        100 => "throwing a projectile weapon at a monster",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

