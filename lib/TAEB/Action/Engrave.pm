#!/usr/bin/env perl
package TAEB::Action::Engrave;
use Moose;
extends 'TAEB::Action';

use constant command => 'E';

has implement => (
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
    my $engraver = $self->implement;

    return $engraver->slot if blessed $engraver;
    return $engraver;
}

sub respond_write_with    { shift->engrave_slot }
sub respond_write_what    { shift->text . "\n" }
sub respond_add_engraving { 'y' }

make_immutable;

1;

