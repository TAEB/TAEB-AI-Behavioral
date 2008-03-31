#!/usr/bin/env perl
package TAEB::Action::Drop;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "Da\n";

has got_identifying_message => (
    isa     => 'Bool',
    default => 0,
);

# logic is elsewhere sadly

sub msg_ring {
    my $self = shift;
    $self->got_identifying_message(1);
    $self->item->rule_out_all_but(@_);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

