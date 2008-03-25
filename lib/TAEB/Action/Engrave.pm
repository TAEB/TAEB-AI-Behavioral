#!/usr/bin/env perl
package TAEB::Action::Engrave;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Item';

use constant command => 'E';

has '+item' => (
    default => '-',
);

has text => (
    isa     => 'Str',
    default => 'Elbereth',
);

has add_engraving => (
    isa     => 'Bool',
    default => 0,
);

has got_identifying_message => (
    isa     => 'Bool',
    default => 0,
);

sub engrave_slot {
    my $self = shift;
    my $engraver = $self->item;

    return $engraver->slot if blessed $engraver;
    return $engraver;
}

sub respond_write_with    { shift->engrave_slot }
sub respond_write_what    { shift->text . "\n" }
sub respond_add_engraving { shift->add_engraving ? 'y' : 'n' }

sub msg_wand {
    my $self = shift;
    $self->got_identifying_message(1);
    $self->item->rule_out_all_but(@_);
}

sub done {
    my $self = shift;
    return unless blessed $self->item;

    if ($self->item->class eq 'wand') {
        $self->item->spend_charge;
    }
    elsif ($self->item->identity eq 'magic marker') {
        $self->item->spend_charge(int(length($self->text) / 2));
    }

    return if $self->got_identifying_message;
    return if $self->item->identity; # perhaps we identified it?
    $self->item->possibility_tracker->no_engrave_message;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

