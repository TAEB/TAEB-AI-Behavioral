package TAEB::AI::Behavioral::Behavior::Projectiles;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    return unless TAEB->current_level->has_enemies;

    # do we have a projectile to throw?
    my $projectile = TAEB->inventory->has_projectile;
    return unless defined $projectile;

    my ($direction, $distance, $tile) = TAEB->current_level->radiate(
        sub {
            my $tile = shift;

            # if the enemy is seen through warning, then we *probably* can't
            # reach him with a projectile
            # warning is not a stopper because it's simpler here AND because if
            # there's a monster in the light beyond the warning monster
            # then we can hit the intervening warning monster
            $tile->has_enemy && !$tile->monster->is_seen_through_warning
                             && $tile->monster->currently_seen;
        },
        max     => $projectile->throw_range,
        stopper => sub {
            my $tile = shift;
            # sinks block projectiles, apparently
            $tile->has_friendly || $tile->type eq 'sink';
        },
    );

    # no monster found
    return if !$direction;

    return if $tile->in_shop;

    $self->do(throw =>
        projectile  => $projectile,
        direction   => $direction,
        target_tile => $tile,
    );
    $self->currently("Throwing a projectile at a monster.");
    $self->urgency('normal');
}

use constant max_urgency => 'normal';

sub pickup {
    my $self = shift;
    my $item = shift;

    $item->match(
        identity => qr/\b(?:dagger|dart|shuriken|spear)\b/,
        '!buc' => 'cursed'
    );
}

__PACKAGE__->meta->make_immutable;

1;

