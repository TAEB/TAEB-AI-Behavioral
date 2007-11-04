#!/usr/bin/env perl
package TAEB::Config;
use Moose;
use YAML;
use Hash::Merge 'merge';
Hash::Merge::set_behavior('RIGHT_PRECEDENT');

has file => (
    is      => 'ro',
    isa     => 'Str',
    default => 'etc/config.yml',
);

has contents => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

sub BUILD {
    my $self = shift;

    my @config = $self->file;

    my %seen;

    while (my $file = shift @config) {
        next if $seen{$file}++;

        warn "Loading config file $file";

        my $config = YAML::LoadFile($file);
        $self->contents(merge($self->contents, $config));

        # if this config specified other files, load them too
        if ($config->{other_config}) {
            my $c = $config->{other_config};
            if (ref($c) eq 'ARRAY') {
                push @config, @$c;
            }
            elsif (ref($c) eq 'HASH') {
                push @config, keys %$c;
            }
            else {
                push @config, $c;
            }
        }
    }
}

1;

