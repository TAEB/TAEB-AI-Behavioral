#!/usr/bin/env perl
package TAEB::Action::Move;
use TAEB::OO;
extends 'TAEB::Action';
use TAEB::Util 'vi2delta';

has path => (
    isa => 'TAEB::World::Path',
);

has direction => (
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

    if (TAEB->x - $self->x0 || TAEB->y - $self->y0 || TAEB->z - $self->z0) {
        TAEB->enqueue_message('walked');

        # the rest applies only if we haven't moved
        return;
    }

    my $dir = substr($self->directions, 0, 1);
    my ($dx, $dy) = vi2delta($dir);

    $self->handle_items_in_rock($dx, $dy);
    $self->handle_obscured_doors($dx, $dy);
}

sub handle_items_in_rock {
    my $self = shift;
    my $dx   = shift;
    my $dy   = shift;

    my $tile = TAEB->current_tile;
    return if $tile->type eq 'trap'; # XXX check that it's a bear trap or pit

    my $dest = TAEB->current_level->at(TAEB->x + $dx, TAEB->y + $dy);

    # the second clause here is for when handle_obscured_doors is run
    return unless $dest->type eq 'obscured'
               || ($dest->type eq 'opendoor' && $dest->glyph eq '-');

    $dest->is_really_rock(1);
    $dest->change_type('rock' => ' ');
}

sub handle_obscured_doors {
    my $self = shift;
    my $dx   = shift;
    my $dy   = shift;

    return unless $dx && $dy;

    # we only care if the tile was obscured
    for ([TAEB->x, TAEB->y], [TAEB->x + $dx, TAEB->y + $dy]) {
        my $tile = TAEB->current_level->at(@$_);
        next unless $tile->type eq 'obscured';

        TAEB->debug("Changing tile at (" . $tile->x . ", " . $tile->y . ") from obscured to opendoor because I tried to move diagonally off or onto it and I didn't move.");
        $tile->change_type('opendoor' => '-');
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

