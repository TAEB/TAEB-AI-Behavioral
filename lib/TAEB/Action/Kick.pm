#!/usr/bin/env perl
package TAEB::Action::Kick;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Direction';

has '+direction' => (
    required => 1,
    provided => 1,
);

# ctrl-D
use constant command => chr(4);

# sorry sir!
sub respond_buy_door { 'y' }

sub msg_dishwasher { shift->target_tile('sink')->got_foocubus(1) }
sub msg_pudding    { shift->target_tile('sink')->got_pudding(1) }
sub msg_ring_sink  { shift->target_tile('sink')->got_ring(1) }

sub done {
    my $self = shift;
    my $target = $self->target_tile;
    $target->kicked($target->kicked + 1) if $target->can('kicked');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

