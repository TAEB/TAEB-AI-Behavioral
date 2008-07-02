#!/usr/bin/env perl
package TAEB::AI::Behavior::GetPudding;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return 0 unless TAEB->can_kick;
    return 0 unless TAEB->current_level->has_type('sink');

    my ($sink, $dir);
    my $check = sub {
        my ($tile, $d) = @_;
        return ($sink, $dir) = ($tile, $d)
            if $tile->type eq 'sink'
            && $tile->glyph eq '{' # no items or monsters on it
            && !$tile->got_pudding
            && $tile->kicked < 50;

        return 0;
    };

    if (TAEB->any_adjacent($check)) {
        $self->do(kick => direction => $dir);
        $self->currently("Kicking a sink for a pudding");
        return 100;
    }

    my $path = TAEB::World::Path->first_match($check, why => "GetPudding");
    $self->if_path($path => "Heading towards a sink");
}

sub urgencies {
    return {
        100 => "kicking an adjacent sink",
         50 => "path to a sink",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

