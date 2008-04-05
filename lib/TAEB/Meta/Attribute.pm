#!/usr/bin/env perl
package TAEB::Meta::Attribute;
use Moose;
extends 'Moose::Meta::Attribute';

has '+is' => (
    default => 'rw',
);

has 'provided' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

around _process_options => sub {
    my $orig = shift;
    my ($class, $name, $options) = @_;

    $options->{is} ||= 'rw';

    $orig->(@_);
};

sub clone_and_inherit_options {
    my ($self, %options) = @_;

    if ($options{isa}) {
        my $type_constraint;
        if (blessed($options{isa}) && $options{isa}->isa('Moose::Meta::TypeConstraint')) {
            $type_constraint = $options{isa};
        }
        else {
            $type_constraint = Moose::Util::TypeConstraints::find_or_create_type_constraint(
                $options{isa}
            );
            (defined $type_constraint)
                || confess "Could not find the type constraint '" . $options{isa} . "'";
        }
        $options{type_constraint} = $type_constraint;
        delete $options{isa};
    }


    $self->clone(%options);
}

no Moose;

1;

