package TAEB::AI::Behavioral::Behavior::Luckstone;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';
use TAEB::Util 'refaddr';

has kicked_stone => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

sub _tile_includes_only {
    my ($tile, @sought_items) = @_;
    my @tile_items = $tile->items;

    # for now, consider only a single item on the tile for simplicity
    return if @tile_items != 1;

    my $tile_item = $tile_items[0];

    for (@sought_items) {
        return $_ if $_ == $tile_item;
    }

    return;
}

sub _tile_allows_kicking {
    my $tile = shift;

    my $from_tile;
    $tile->each_adjacent(sub {
        my ($t, $d) = @_;
        return unless $t->is_walkable;
        return unless $tile->from_direction($d)->is_walkable;

        $from_tile = $tile->from_direction($d);
    });

    return $from_tile;
}

sub find_possible_luckstones {
    my $self = shift;

    # is there a possible luckstone on the level?
    my (@possible_luckstones) = grep {
        $_->has_tracker && $_->tracker->includes_possibility('luckstone')
    } TAEB->current_level->items;

    # are there any that haven't been kicked?
    @possible_luckstones = grep { !$self->kicked_stone->{refaddr $_} }
                           @possible_luckstones;

    return @possible_luckstones;
}

sub handle_adjacent_luckstone {
    my ($self, @possible_luckstones) = @_;

    # any unkicked gray stones adjacent to us? if so, kick!
    my ($tile, $direction);
    TAEB->each_adjacent(sub {
        my ($t, $d) = @_;
        my $luckstone = _tile_includes_only($t, @possible_luckstones);
        return unless $luckstone;

        ($tile, $direction) = ($t, $d);
    });

    if ($tile) {
        if ($tile->at_direction($direction)->is_walkable) {
            $self->currently("Kicking a possible luckstone.");
            $self->do(kick => direction => $direction);
            $self->urgency('unimportant');
            return 1;
        }

        # find a place from which we can kick the luckstone
        if (my $from_tile = _tile_allows_kicking($tile)) {
            return $self->if_path(
                TAEB::World::Path->calculate_path($from_tile),
                "Heading towards a luckstone's kicking vantage point",
                'unimportant',
            );
        }
    }

    return;
}

sub handle_level_luckstone {
    my ($self, @possible_luckstones) = @_;

    my $path = TAEB::World::Path->first_match(sub {
        my $tile = shift;
        return unless _tile_includes_only($tile, @possible_luckstones);
        return unless _tile_allows_kicking($tile);
        return 1;
    });

    return $self->if_path(
        $path,
        'Heading towards a possible luckstone',
        'unimportant',
    );
}

sub prepare {
    my $self = shift;

    my @possible_luckstones = $self->find_possible_luckstones
        or return;

    my $action = $self->handle_adjacent_luckstone(@possible_luckstones);
    return $action if $action;

    $action = $self->handle_level_luckstone(@possible_luckstones);
    return $action if $action;
}

sub done {
    my $self = shift;
    my $action = $self->action;

    return unless $self->action->isa('TAEB::Action::Kick');
    my $tile = $self->action->target_tile;

    if (_tile_includes_only($tile, $self->find_possible_luckstones)) {
        my ($item) = $tile->items;
        $self->kicked_stone->{refaddr $item} = 1;
    }
}

__PACKAGE__->meta->make_immutable;

1;

