#!/usr/bin/env perl
package TAEB::AI::Behavior::Projectiles;
use Moose;
extends 'TAEB::AI::Behavior';

has projectile => (
    is  => 'rw',
    isa => 'TAEB::World::Item',
);

sub prepare {
    my $self = shift;

    # do we have a projectile to throw?
    my $projectile = TAEB->inventory->find(sub { $self->pickup(@_) })
        or return 0;

    my $direction = TAEB->current_level->radiate(
        sub { shift->has_monster },

        # how far to radiate. we can eventually calculate how far $projectile
        # can travel..!
        max => 6,
    );

    # no monster found
    return 0 if !$direction;

    $self->projectile($projectile);
    $self->next(join '', 't', $projectile->slot, $direction);
    $self->currently("Throwing a $projectile at a monster.");
    return 100;
}

after next_action => sub {
    my $self = shift;

    # mark that we've thrown the item
    TAEB->inventory->decrease_quantity($self->projectile->slot);
};

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

1;

