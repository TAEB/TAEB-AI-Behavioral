#!/usr/bin/env perl
package TAEB::AI::Personality::Human;
use Moose;
use Term::ReadKey;
extends 'TAEB::AI::Personality';

=head1 NAME

TAEB::AI::Personality::Human - the only personality that has a chance

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 institute

This will put the terminal in the correct read mode.

=cut

sub institute {
    ReadMode(3);
};

=head2 next_action TAEB -> STRING

This will consult a magic 8-ball to determine what move to make next.

=cut

sub next_action {
    ReadKey(0);
}

=head1 IDEA BY

arcanehl

=cut

1;

