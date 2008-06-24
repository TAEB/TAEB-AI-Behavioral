#!/usr/bin/env perl
package TAEB::Action::Apply;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "a";

has item => (
    traits   => [qw/TAEB::Provided/],
    isa      => 'TAEB::World::Item',
    required => 1,
);

sub respond_apply_what { shift->item->slot }

sub msg_nothing_happens {
    my $self = shift;
    my $item = $self->item;

    # nothing happens is good! we know we don't have these status effects
    if ($item->match(identity => 'unicorn horn')) {
        for (qw/blindness confusion stunning hallucination/) {
            TAEB->enqueue_message(status_change => $_ => 0);
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

