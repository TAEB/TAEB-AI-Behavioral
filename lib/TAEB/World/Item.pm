#!/usr/bin/env perl
package TAEB::World::Item;
use Moose;

has appearance => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has slot => (
    is  => 'rw',
    isa => 'Str',
);

=head2 matches (Str|Regexp|CODE) -> Bool

Does the given item look sufficiently like this item?

This is intentionally vague because I don't know what I want yet.

=cut

sub matches {
    my $self = shift;
    my $item = shift;

    if (ref($item eq 'Regexp')) {
        return $self->appearance =~ $item;
    }
    elsif (ref($item eq 'CODE')) {
        return $item->($self->appearance);
    }

    return $self->appearance eq $item;
}

1;

