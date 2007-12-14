#!/usr/bin/env perl
package TAEB::AI::Senses;
use Moose;

has hp => (
    is => 'rw',
    isa => 'Int',
);

has maxhp => (
    is => 'rw',
    isa => 'Int',
);

sub update {
    my $self = shift;
    my $botl = $main::taeb->vt->row_plaintext(23);

    if ($botl =~ /HP:(\d+)\((\d+)\)/) {
        $self->hp($1);
        $self->maxhp($2);
    }
    else {
        $main::taeb->error("Unable to parse HP from '$botl'");
    }
}

1;

