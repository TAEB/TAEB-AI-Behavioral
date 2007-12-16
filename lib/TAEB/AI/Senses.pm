#!/usr/bin/env perl
package TAEB::AI::Senses;
use Moose;

has hp => (
    is  => 'rw',
    isa => 'Int',
);

has maxhp => (
    is  => 'rw',
    isa => 'Int',
);

has in_wereform => (
    is  => 'rw',
    isa => 'Bool',
);

has can_kick => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

sub update {
    my $self = shift;

    my $status = TAEB->vt->row_plaintext(22);
    my $botl   = TAEB->vt->row_plaintext(23);

    if ($botl =~ /HP:(\d+)\((\d+)\)/) {
        $self->hp($1);
        $self->maxhp($2);
    }
    else {
        TAEB->error("Unable to parse HP from '$botl'");
    }

    $self->in_wereform($status =~ /^TAEB the Were/ ? 1 : 0);

    if (TAEB->messages =~ /You can't move your leg/
     || TAEB->messages =~ /You are caught in a bear trap/) {
        $self->can_kick(0);
    }
    # XXX: there's no message when you leave a bear trap. I'm not sure of the
    # best solution right now. a way to say "run this code when I move" maybe

}

1;

