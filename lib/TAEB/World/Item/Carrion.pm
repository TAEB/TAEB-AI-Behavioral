#!/usr/bin/env perl
package TAEB::World::Item::Carrion;
use TAEB::OO;
use TAEB::Spoilers::Monster;
extends 'TAEB::World::Item::Food';

has is_forced_verboten => (
    isa     => 'Bool',
    default => 0,
);

has estimated_date => (
    isa     => 'Bool',
    default => 0,
);

sub estimate_age { TAEB->turn - shift->estimated_date; }

__PACKAGE__->install_spoilers('corpse');

for my $attribute ('poisonous', 'weight', 'nutrition') {
    __PACKAGE__->meta->add_method($attribute => sub {
        shift->corpse->{$attribute}
    });
}

for my $resistance ('poison', 'fire') {
    my $method = $resistance . '_resistance';
    __PACKAGE__->meta->add_method($method => sub {
        shift->corpse->{$attribute}
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

