#!/usr/bin/env perl
package TAEB::Action::Drop;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Item';

use constant command => "Da\n";

# logic is elsewhere sadly

sub msg_ring {
    my $self     = shift;
    my $identity = shift;
    TAEB->debug("Identified ".$self->item->appearance." as $identity");
    $self->item->identify_as($identity);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

