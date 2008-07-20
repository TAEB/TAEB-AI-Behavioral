#!/usr/bin/env perl
package TAEB::Meta::Role::Initialize;
use Moose::Role;

sub initialize {
    my $self = shift;

    for my $attr ($self->meta->compute_all_applicable_attributes) {
        next if $attr->is_weak_ref;

        my $reader = $attr->get_read_method_ref;
        my $class = $reader->($self);
        next unless blessed($class) && blessed($class) =~ /^TAEB/;

        if ($class->can('initialize')) {
            $class->initialize;
        }
    }
}

no Moose::Role;

1;

