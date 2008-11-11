#!/usr/bin/env perl
package TAEB::Meta::Role::Initialize;
use Moose::Role;

sub initialize { }
after initialize => sub {
    my $self = shift;

    my @attrs = $self->meta->compute_all_applicable_attributes;
    push @attrs, $self->meta->compute_all_applicable_class_attributes
        if $self->meta->can('compute_all_applicable_class_attributes');

    for my $attr (@attrs) {
        next if $attr->is_weak_ref;

        my $reader = $attr->get_read_method_ref;
        my $value  = $reader->($self);
        next unless blessed($value);

        my $meta = Class::MOP::Class->initialize(blessed $value);
        if ($meta && $meta->does_role(__PACKAGE__)) {
            $value->initialize;
        }
    }
};

no Moose::Role;

1;

