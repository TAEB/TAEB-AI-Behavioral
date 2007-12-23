#!/usr/bin/env perl
package TAEB::AI::Behavior::Fight;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    if (TAEB->hp * 2 < TAEB->maxhp && !TAEB->senses->in_wereform) {
        $self->currently("Writing Elbereth.");
        return "E-  Elbereth\n";
    }

    my $found_monster;
    TAEB->each_adjacent(sub {
        my ($tile, $dir) = @_;
        if ($tile->has_monster) {
            $self->commands([$dir]);
            $self->currently("Attacking a " . $tile->glyph);
            $found_monster = 1;
        }
    });
    return 90 if $found_monster;

    return 0 unless TAEB->map_like(qr/\]/);
    return 0 unless TAEB->map_like(qr/[a-zA-Z~&';:]/);

    my $path = TAEB::World::Path->first_match(
        sub { shift->has_monster },
    );
    $self->currently("Heading towards a " . $path->to->tile . " monster");
    $self->path($path);

    return $path && length($path->path) ? 80 : 0;
}

1;

