#!/usr/bin/env perl
package TAEB::Meta::Role::Initialize;
use Moose::Role;

sub initialize {
    my $self = shift;

    for my $attr ($self->meta->compute_all_applicable_attributes) {
        next if $attr->is_weak_ref;

        my $reader = $attr->get_read_method_ref;
        my $class  = $reader->($self);
        next unless blessed($class);

        if ($class->can('does') && $class->does(__PACKAGE__)) {
            $class->initialize;
        }
    }
}

no Moose::Role;

1;

