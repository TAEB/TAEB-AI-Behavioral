#!perl
package TAEB;
use Moose;
use Term::VT102::ZeroBased;

=head1 NAME

TAEB - Tactical Amulet Extraction Bot

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

has interface =>
(
    is       => 'rw',
    isa      => 'TAEB::Interface',
    required => 1,
);

has brain =>
(
    is       => 'rw',
    isa      => 'TAEB::Brain',
    required => 1,
);

has vt =>
(
    is => 'rw',
    isa => 'Term::VT102::ZeroBased',
    required => 1,
    default => sub {
        Term::VT102::ZeroBased->new(cols => 80, rows => 24)
    },
);

=head2 step

This will perform one input/output iteration of TAEB.

It will return any input it receives, so you can follow along at home.

=cut

sub step {
    my $self = shift;

    my $input = $self->process_input;

    my $next_action = $self->brain->next_action($self);
    $self->interface->write($next_action);

    return $input;
}

=head2 process_input

This will read the interface for input and update the VT object.

It will return any input it receives, so C<step> can follow along at home.

=cut

sub process_input {
    my $self = shift;

    my $input = $self->interface->read;

    $self->vt->process($input);

    return $input;
}

1;

