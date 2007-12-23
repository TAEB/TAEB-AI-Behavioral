#!/usr/bin/env perl
package TAEB::AI::Behavior::Fight;
use Moose;
extends 'TAEB::AI::Behavior';

=head2 prepare -> Int

100: writing Elbereth
90: attacking an adjacent monster
50: path to the nearest monster

=cut

sub prepare {
    my $self = shift;

    if (TAEB->hp * 2 < TAEB->maxhp && !TAEB->senses->in_wereform) {
        $self->currently("Writing Elbereth.");
        $self->commands(["E-  Elbereth\n"]);
        return 100;
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

    return 0 unless $path && $path->path;

    $self->currently("Heading towards a " . $path->to->tile . " monster");
    $self->path($path);

    return 50;
}

1;

