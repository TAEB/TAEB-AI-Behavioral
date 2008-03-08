#!/usr/bin/env perl
package TAEB::Action::Engrave;
use Moose;
extends 'TAEB::Action';

use constant command => 'E';

has engraver => (
    is      => 'rw',
    isa     => 'TAEB::World::Item | Str',
    default => '-',
);

has text => (
    is      => 'rw',
    isa     => 'Str',
    default => 'Elbereth',
);

sub engrave_slot {
    my $self = shift;
    my $engraver = $self->engraver;

    return $engraver->slot if blessed $engraver;
    return $engraver;
}

1;

