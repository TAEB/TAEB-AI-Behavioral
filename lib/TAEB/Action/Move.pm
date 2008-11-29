#!/usr/bin/env perl
package TAEB::Action::Move;
use TAEB::OO;
extends 'TAEB::Action';
use TAEB::Util 'vi2delta';

with 'TAEB::Action::Role::Direction';

has path => (
    isa => 'TAEB::World::Path',
);

has '+direction' => (
    required => 0,
);

has starting_tile => (
    isa     => 'TAEB::World::Tile',
    default => sub { TAEB->current_tile },
);

has hit_obscured_monster => (
    isa     => 'Bool',
    default => 0,
);

# if the first movement is < or >, then just use the Ascend or Descend actions
# if the first movement would move us into a monster, rest instead
around new => sub {
    my $orig  = shift;
    my $class = shift;
    my %args  = @_;

    # we only want to change Move
    return $class->$orig(@_) if $class ne 'TAEB::Action::Move';

    my $action;
    my $start;

    confess "You must specify a path or direction to the Move action."
        unless $args{path} || $args{direction};

    $start = substr($args{path}->path, 0, 1) if $args{path};
    $start = substr($args{direction},  0, 1) if $args{direction};

    if ($start eq '<') {
        $action = 'Ascend';
    }
    elsif ($start eq '>') {
        $action = 'Descend';
    }
    else {
        # XXX: this code is temporary. if the AI says to move, we move. since
        # our framework can't always cope with that, we have these workarounds
        my $monster = TAEB->current_level->at_direction($start)->monster;
        if (defined $monster && $monster->can_move) {
            TAEB->info("Trying to move into an uncooperative " .
                $monster->glyph . "; Elberething instead.");
            if ($monster->respects_elbereth && TAEB->elbereth_count == 0) {
                $action = 'Engrave';
            }
            elsif (!defined($monster->is_shk) || $monster->is_shk) {
                # Shopkeeps don't usually move unless we do ...
                my @poss;
                TAEB->current_tile->each_adjacent(sub {
                    my ($tile, $dir) = @_;
                    push @poss, $dir if $tile->is_walkable
                                     && !$tile->has_monster;
                });

                if (@poss) {
                    $action = 'Move';
                    $args{direction} = $poss[rand @poss];
                } else {
                    $action = 'Search';
                }
            }
            else {
                $action = 'Search';
                $args{iterations} = 1;
            }
        }
    }

    if ($action) {
        return "TAEB::Action::$action"->new(%args);
    }

    $class->$orig(%args);
};

sub directions {
    my $self = shift;
    return $self->direction || $self->path->path;
}

sub command {
    my $self = shift;

    # XXX: this will break when we have something like stepping onto a teleport
    # trap with TC (intentionally)
    return substr($self->directions, 0, 1);
}

# if we didn't move, and we tried to move diagonally, and the tile we're trying
# to move onto (or off of) is obscured, then assume that tile is a door.
# XXX: we could also be # in a pit or bear trap
sub done {
    my $self = shift;

    my $walked = TAEB->x - $self->starting_tile->x
              || TAEB->y - $self->starting_tile->y
              || TAEB->z - $self->starting_tile->z;

    if ($walked) {
        TAEB->enqueue_message('walked');

        # the rest applies only if we haven't moved
        return;
    }

    return if $self->hit_obscured_monster;

    my $dir = substr($self->directions, 0, 1);
    my ($dx, $dy) = vi2delta($dir);

    $self->handle_obscured_doors($dx, $dy);
    $self->handle_items_in_rock($dx, $dy);
}

sub handle_items_in_rock {
    my $self = shift;
    my $dx   = shift;
    my $dy   = shift;

    my $tile = TAEB->current_tile;
    return if $tile->type eq 'trap' && ($tile->trap_type eq 'bear trap'
                                     || $tile->trap_type eq 'pit'
                                     || $tile->trap_type eq 'spiked pit'
                                     || $tile->trap_type eq 'web');
    return if $tile->type eq 'opendoor' && $dx && $dy;

    my $dest = TAEB->current_level->at(TAEB->x + $dx, TAEB->y + $dy);

    # the second clause here is for when handle_obscured_doors is run
    # the third clause here is because we assume floors that go to ' ' are dark
    # room tiles
    return unless $dest->type eq 'obscured'
               || ($dest->type eq 'opendoor' && $dest->floor_glyph eq '-')
               || ($dest->type eq 'floor' && $dest->glyph eq ' ');

    $dest->change_type('rock' => ' ');
}

sub handle_obscured_doors {
    my $self = shift;
    my $dx   = shift;
    my $dy   = shift;

    # can't move? then don't bother
    return unless TAEB->can_move;

    # obscured doors only affect us when we move diagonally
    return unless $dx && $dy;

    # we only care if the tile was obscured
    for ([TAEB->x, TAEB->y], [TAEB->x + $dx, TAEB->y + $dy]) {
        my $tile = TAEB->current_level->at(@$_);
        next unless $tile->type eq 'obscured';

        TAEB->debug("Changing tile at (" . $tile->x . ", " . $tile->y . ") from obscured to opendoor because I tried to move diagonally off or onto it and I didn't move.");
        $tile->change_type('opendoor' => '-');
    }
}

# falling into a trapdoor makes the new level the same branch as the old level
sub msg_trapdoor {
    my $self = shift;

    TAEB->current_level->branch($self->starting_tile->branch)
        if $self->starting_tile->known_branch
}

sub msg_got_item {
    my $self = shift;
    TAEB->enqueue_message(remove_floor_item => @_);
}

sub msg_hidden_monster { shift->hit_obscured_monster(1) }

sub location_controlled_tele {
    my $self = shift;
    my $target = $self->path->to;
    return $target if $target->is_walkable && !$target->has_monster;
    my @adjacent = $target->grep_adjacent(sub {
        my $t = shift;
        return $t->is_walkable && !$t->has_monster;
    });
    return unless @adjacent;
    return $adjacent[0];
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

