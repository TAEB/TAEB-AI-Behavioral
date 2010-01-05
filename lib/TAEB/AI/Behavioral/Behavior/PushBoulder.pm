package TAEB::AI::Behavioral::Behavior::PushBoulder;
use Moose;
use TAEB::OO;
use TAEB::Util qw/delta2vi vi2delta/;
extends 'TAEB::AI::Behavioral::Behavior';

sub push_direction {
    my $tile = shift;

    return '.' unless $tile->is_walkable;

    my @tiles = $tile->grep_adjacent(sub {
        my $t = shift;
        my $beyond = $t->level->at($t->x * 2 - $tile->x, $t->y * 2 - $tile->y);
        return 0 unless defined $beyond;
        return 0 unless $t->has_boulder;
        return 0 unless $beyond->type eq 'unexplored';
        return 0 if $beyond->has_monster;
        return 1;
    });
    return '.' unless @tiles;

    return delta2vi($tiles[0]->x - $tile->x, $tiles[0]->y - $tile->y);
}

sub prepare {
    my $self = shift;

    return if (TAEB->current_level->branch||'') eq 'sokoban';

    # XXX: TAEB should track each boulder on the level. iterate over the
    # boulders and find one that looks usefully-pushable

    my $path = TAEB::World::Path->first_match(sub {
        push_direction(shift) ne '.';
    });

    my $push_dir = push_direction(TAEB->current_tile);

    if ($path && $path->path eq '' && $push_dir ne '.') {
        $self->currently("Pushing an adjacent boulder");
        $self->do(move => direction => $push_dir);
        $self->urgency('fallback');
        return;
    }

    $self->if_path($path => "Heading to a pushable edge boulder");
}

use constant max_urgency => 'fallback';

__PACKAGE__->meta->make_immutable;

1;

