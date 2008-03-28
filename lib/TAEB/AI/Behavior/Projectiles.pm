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

    return 0 unless TAEB->vt->as_string('', 1, 21) =~ /[a-zA-Z&\@';:1-5]/;

    # do we have a projectile to throw?
    my $projectile;
    for (@projectiles) {
        $projectile = TAEB->find_item($_) and last;
    }
    return 0 unless defined $projectile;

    my $direction = TAEB->current_level->radiate(
        sub { shift->has_enemy },
        max => $projectile->throw_range,
    );

    # no monster found
    return 0 if !$direction;

    $self->do(throw => item => $projectile, direction => $direction);
    $self->currently("Throwing a projectile at a monster.");
    return 100;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    $item->identity =~ m{
        \b(?:dagger|dart|shuriken|boomerang|spear)\b
    }x && $item->buc ne 'cursed';
}

sub urgencies {
    return {
        100 => "throwing a projectile weapon at a monster",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

