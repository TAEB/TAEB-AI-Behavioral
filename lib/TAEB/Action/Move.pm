#!/usr/bin/env perl
package TAEB::Action::Move;
use TAEB::OO;
extends 'TAEB::Action';
use TAEB::Util 'vi2delta';

has path => (
    is  => 'rw',
    isa => 'TAEB::World::Path',
);

has direction => (
    is  => 'rw',
    isa => 'Str',
);

has x0 => (
    is      => 'ro',
    isa     => 'Int',
    default => sub { TAEB->x },
);

has y0 => (
    is      => 'ro',
    isa     => 'Int',
    default => sub { TAEB->y },
);

has z0 => (
    is      => 'ro',
    isa     => 'Int',
    default => sub { TAEB->z },
);

sub BUILD {
    my $self = shift;

    confess "You must specify a path or direction to the Move action."
        unless $self->path || $self->direction;
}

sub directions {
    my $self = shift;
    return $self->direction || $self->path->path;
}

sub command {
    my $self = shift;

    # XXX: this will break when we have something like stepping onto a teleport
    # trap with TC (intentionally)
    return substr($self->directions, 0, 1);
}

# if we didn't move, and we tried to move diagonally, and the tile we're trying
# to move onto (or off of) is obscured, then assume that tile is a door.
# XXX: we could also be # in a pit or bear trap
sub done {
    my $self = shift;

    # we only care if we didn't move
    return if TAEB->x - $self->x0
           || TAEB->y - $self->y0
           || TAEB->z - $self->z0;

    TAEB->enqueue_message('walked');

    my $dir = substr($self->directions, 0, 1);
    my ($dx, $dy) = vi2delta($dir);

    # we only care if we tried to move diagonally
    return unless $dx && $dy;

    # we only care if the tile was obscured
    for ([TAEB->x, TAEB->y], [TAEB->x + $dx, TAEB->y + $dy]) {
        my $tile = TAEB->current_level->at(@$_);
        return unless $tile->type eq 'obscured';

        TAEB->debug("Changing tile at (" . $tile->x . ", " . $tile->y . ") from obscured to opendoor because I tried to move diagonally off or onto it and I didn't move.");
        $tile->type('opendoor');
    }
}

make_immutable;

1;

