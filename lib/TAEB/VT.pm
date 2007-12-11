#!/usr/bin/env perl
package TAEB::VT;
use Moose;
extends 'Term::VT102::ZeroBased';

=head2 topline

Returns the top line of text. Merely a convenience function.

=cut

sub topline {
    my $self = shift;
    $self->row_plaintext(0);
}

=head2 find_row CODE

This is used to iterate over the virtual terminal's rows, looking for something.
The callback receives the contents of each row in turn.

If the callback returns a true value, then the find_row method will return
the current row's index.

If the callback returns all false values, then the find_row method will
return C<undef>.

=cut

sub find_row {
    my $self = shift;
    my $cb = shift;

    for my $row (0 .. $self->rows - 1) {
        return $row if $cb->($self->row_plaintext($row));
    }

    return;
}

=head2 contains Str -> Bool

Returns whether the specified string is contained in the virtual terminal's
contents.

=cut

sub contains {
    my $self = shift;
    my $text = shift;

    defined $self->find_row(sub { index($_[0], $text) >= 0 });
}

=head2 matches Regexp -> Bool

Returns whether the specified regex matches any of the VT's rows.

=cut

sub matches {
    my $self = shift;
    my $re = shift;

    defined $self->find_row(sub { $_[0] =~ $re });
}

=head2 at Int, Int -> Char

Returns the character at the specified (row, col)

=cut

sub at {
    my $self = shift;
    my $x    = shift;
    my $y    = shift;

    $self->row_plaintext($y, $x, $x);
}

1;

