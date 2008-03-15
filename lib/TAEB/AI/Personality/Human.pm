#!/usr/bin/env perl
package TAEB::AI::Personality::Human;
use TAEB::OO;
use Term::ReadKey;
extends 'TAEB::AI::Personality';

=head1 NAME

TAEB::AI::Personality::Human - the only personality that has a chance

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 next_action TAEB -> STRING

This will consult a magic 8-ball to determine what move to make next.

=cut

sub _get_key {
    ReadMode 3;
    my $c = ReadKey(0);
    ReadMode 0;
    return $c;
}

sub next_action {
    while (1) {
        my $c = _get_key;

        if ($c eq "~") {
            my $out = TAEB->keypress(_get_key);
            if (defined $out) {
                TAEB->out("\e[2H\e[44m$out");
                sleep 3;
                TAEB->out(TAEB->redraw);
            }
        }
        else {
            return TAEB::Action->new_action(custom => string => $c);
        }
    }
}

=head1 IDEA BY

arcanehl

=cut

make_immutable;
no Moose;

1;

