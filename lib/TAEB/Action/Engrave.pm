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

has got_identifying_message => (
    isa     => 'Bool',
    default => 0,
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

sub msg_wand {
    my $self = shift;
    $self->got_identifying_message(1);
    $self->implement->rule_out_all_but(@_);
}

sub done {
    my $self = shift;
    return unless blessed $self->implement;
    return if $self->got_identifying_message;
    return if $self->implement->identity; # perhaps we identified it?
    $self->implement->possibility_tracker->no_engrave_message;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

