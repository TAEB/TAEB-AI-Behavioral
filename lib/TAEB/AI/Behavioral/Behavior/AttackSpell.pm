package TAEB::AI::Behavioral::Behavior::AttackSpell;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub use_spells { ('magic missile', 'sleep', 'force bolt') }

sub use_wands {
    map { "wand of $_" }
    'striking', 'sleep', 'death', 'magic missile', 'cold', 'fire', 'lightning'
}

sub prepare {
    my $self = shift;

    return unless TAEB->current_level->has_enemies;

    my ($spell, $wand);
    for ($self->use_spells) {
        $spell = TAEB->find_castable($_);
        next unless $spell;
        TAEB->log->behavior("Considering spell $spell");
        if ($self->try_to_cast(spell => $spell)) {
            $self->urgency('normal');
            return;
        }
    }

    unless ($spell) {
        for my $desired ($self->use_wands) {
            $wand = TAEB->has_item(identity => $desired,
                                   charges  => [undef, sub { $_ > 0 }]);
            next unless $wand;
            next if defined $wand->price && $wand->price > TAEB->gold;
            TAEB->log->behavior("Considering wand $wand");
            if ($self->try_to_cast(wand => $wand)) {
                $self->urgency('normal');
                return;
            }
        }
    }
}

use constant max_urgency => 'normal';

my %resist = (
    'wand of fire'      => sub { TAEB->fire_resistant },
    'wand of lightning' => sub { TAEB->shock_resistant },
    #XXX magic resistance
    'wand of cold'      => sub { TAEB->cold_resistant },
    'wand of sleep'     => sub { TAEB->sleep_resistant },
    'sleep'             => sub { TAEB->sleep_resistant },
);

sub try_to_cast {
    my $self = shift;
    my %args = @_;
    my $spell = $args{spell};
    my $wand = $args{wand};
    my $thing = defined $spell ? $spell->name : $wand->identity;

    my $direction = TAEB->current_level->radiate(
        sub { 
            my $tile = shift;
            return 0 unless $tile->has_enemy;
            if ($thing eq 'sleep' || $thing eq 'wand of sleep') {
                return 0 unless $tile->monster->is_sleepable;
            }
            return 1;
        },
        stopper => sub { shift->has_friendly },
        bouncy => $thing ne "force bolt" && $thing ne "wand of striking",
        allowself => ($resist{$thing} || sub{0})->(),
        # how far to radiate. we can eventually calculate how far beam/ray
        # can travel..!
        max => 6,
    );

    # no monster found
    return 0 if !$direction;

    if ($spell) {
        $self->do(cast => spell => $spell, direction => $direction);
        $self->currently("Casting ".$spell->name." at a monster");
        return 1;
    }

    if ($wand) {
        $self->do(zap => wand => $wand, direction => $direction);
        $self->currently("Zapping a ".$wand->identity." at a monster");
        return 1;
    }

    return 0;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return $item->match(identity => [$self->use_wands]);
}

__PACKAGE__->meta->make_immutable;

1;

