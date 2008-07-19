#!/usr/bin/perl
package TAEB::Object;
use Moose;
extends 'Moose::Object';

sub _app_init {
    my $self = shift;

    for my $attr ($self->meta->compute_all_applicable_attributes) {
        next if $attr->is_weak_ref;

        my $reader = $attr->get_read_method_ref;
        my $class = $reader->($self);
        next unless blessed($class) && blessed($class) =~ /^TAEB/;

        if ($class->can('_app_init')) {
            $class->_app_init;
        }
    }
}

no Moose;

1;
