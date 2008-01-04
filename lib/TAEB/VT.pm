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
The callback receives the contents of each row, and its index, in turn.

If the callback returns a true value, then the find_row method will return
the current row's index.

If the callback returns all false values, then the find_row method will
return C<undef>.

=cut

sub find_row {
    my $self = shift;
    my $cb = shift;

    for my $row (0 .. $self->rows - 1) {
        return $row if $cb->($self->row_plaintext($row), $row);
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

=head2 redraw -> Str

Returns a string that, when printed, will redraw the entire screen, directly as
NetHack looks.

=cut

sub redraw {
    my $self = shift;
    my $out = "\e[H\e[2J";

    for my $y (0 .. 23) {
        my @attrs = $self->row_attr($y) =~ /../g;
        my @chars = split '', $self->row_plaintext($y);

        for (0..$#attrs)
        {
            my %attr;
            @attr{qw/fg bg bold faint standout underline blink reverse/}
                = $self->attr_unpack($attrs[$_]);
            $chars[$_] = $self->attr_to_ansi(%attr) . $chars[$_];
        }
        $out .= sprintf "\e[%dH%s",
                    $y + 1,
                    join '', @chars;
    }

    $out .= sprintf "\e[%d;%dH", $self->y + 1, $self->x + 1;

    return $out;
}

=head2 attr_to_ansi Hash -> Str

Takes a hash with the following keys, and returns the ANSI escape code that can
be used to get those keys set.

=over 4

=item fg

=item bg

=item bold

=item faint

=item standout

=item underline

=item blink

=item reverse

=back

=cut

sub attr_to_ansi
{
    my $self = shift;
    my %args = @_;

    my $fg = 3 . ($args{fg} || 7);
    $fg =~ s/^3(3.)/$1/;

    my $bg = 4 . ($args{bg} || 0);
    $bg =~ s/^4(4.)/$1/;

    my $color = "\e[0";
    $color .= ";1" if $args{bold};
    $color .= ";2" if $args{faint};
    $color .= ";3" if $args{standout};
    $color .= ";4" if $args{underline};
    $color .= ";5" if $args{blink};
    $color .= ";7" if $args{reverse};

    $color .= ";$fg" if $fg != 37;
    $color .= ";$bg" if $bg != 40;

    return $color . 'm';
}

=head2 color Int, Int -> Int

Returns an int representing the color NetHack uses for whatever is occupying the specified tile.

=cut

sub color {
    my $self = shift;
    my $x = shift;
    my $y = shift;

    # fields: fg, bg, bold, faint, standout, underline, blink, reverse
    my @attr = $self->attr_unpack($self->row_attr($y, $x, $x));

    # bold is only 0 or 1
    # this then maps into the constants from color.h (and in Util.pm)
    return $attr[0] + 8*$attr[2];
}

1;

