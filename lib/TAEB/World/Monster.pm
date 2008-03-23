#!/usr/bin/env perl
package TAEB::World::Monster;
use TAEB::OO;
use TAEB::Util qw/:colors/;

has glyph => (
    isa      => 'Str',
    required => 1,
);

has color => (
    isa      => 'Str',
    required => 1,
);

has tile => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
);

sub is_shk {
    my $self = shift;
    $self->glyph eq '@' && $self->color eq COLOR_WHITE;
}

sub is_oracle {
    my $self = shift;
    return 0 if TAEB->z >= 5 && TAEB->z <= 9;
    return 1 if $self->glyph eq '@' && $self->color eq COLOR_BRIGHT_BLUE;
    return 0;
}

sub is_enemy {
    my $self = shift;
    return 0 if $self->is_shk;
    return 0 if $self->is_oracle;
    return 1;
}

sub is_meleeable {
    my $self = shift;

    return 0 unless $self->is_enemy;

    # floating eye (paralysis)
    return 0 if $self->color eq COLOR_BLUE
             && $self->glyph eq 'e';

    # blue jelly (cold)
    return 0 if $self->color eq COLOR_BLUE
             && $self->glyph eq 'j'
             && !TAEB->senses->cold_resistance;

    # spotted jelly (acid)
    return 0 if $self->color eq COLOR_GREEN
             && $self->glyph eq 'j';

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

