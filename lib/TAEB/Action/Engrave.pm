#!/usr/bin/env perl
package TAEB::Action::Engrave;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => 'E';

has implement => (
    isa     => 'TAEB::World::Item | Str',
    default => '-',
);

has text => (
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

__PACKAGE__->meta->make_immutable;
no Moose;

1;

