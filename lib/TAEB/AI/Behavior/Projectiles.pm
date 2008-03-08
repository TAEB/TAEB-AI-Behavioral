#!/usr/bin/env perl
package TAEB::AI::Behavior::Projectiles;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # do we have a projectile to throw?
    my $projectile = TAEB->find_item(sub { $self->pickup(@_) })
        or return 0;

    my $direction = TAEB->current_level->radiate(
        sub { shift->has_monster },

        # how far to radiate. we can eventually calculate how far $projectile
        # can travel..!
        max => 6,
    );

    # no monster found
    return 0 if !$direction;

    $self->do(throw => item => $projectile);
    $self->currently("Throwing a $projectile at a monster.");
    return 100;
}

my %pickup = map { $_ => 1 } qw/dagger dart shuriken/;
sub pickup {
    my $self = shift;
    my $item = shift;
    return $pickup{$item->identity};
}

sub urgencies {
    return {
        100 => "throwing a projectile weapon at a monster",
    };
}

make_immutable;

1;

