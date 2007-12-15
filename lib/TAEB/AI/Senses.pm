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

has in_wereform => (
    is  => 'rw',
    isa => 'Bool',
);

sub update {
    my $self = shift;

    my $status = $main::taeb->vt->row_plaintext(22);
    my $botl   = $main::taeb->vt->row_plaintext(23);

    if ($botl =~ /HP:(\d+)\((\d+)\)/) {
        $self->hp($1);
        $self->maxhp($2);
    }
    else {
        $main::taeb->error("Unable to parse HP from '$botl'");
    }

    $self->in_wereform($status =~ /^TAEB the Were/ ? 1 : 0);
}

1;

