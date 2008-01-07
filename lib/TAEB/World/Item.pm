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

# check whether this is an artifact, and if so, let the artifact-tracker know
# we've seen it
sub BUILD {
    my $artifact = TAEB::Knowledge::Item::Artifact->artifact($self->appearance)
        or return;
    TAEB::Knowledge::Item::Artifact->seen($self->appearance => 1);
}

=head2 matches (Str|Regexp|CODE) -> Bool

Does the given item look sufficiently like this item?

This is intentionally vague because I don't know what I want yet.

If a coderef is passed in, then C<$_> will be the appearance. The coderef will
also get an argument: the item itself.

=cut

sub matches {
    my $self = shift;
    my $item = shift;

    if (ref($item) eq 'Regexp') {
        return $self->appearance =~ $item;
    }
    elsif (ref($item) eq 'CODE') {
        local $_ = $self->appearance;
        return $item->($self);
    }

    return $self->appearance eq $item;
}

1;

