#!/usr/bin/env perl
package TAEB::Meta::Role::Initialize;
use Moose::Role;

sub initialize { }
after initialize => sub {
    my $self = shift;

    for my $attr ($self->meta->compute_all_applicable_attributes) {
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

