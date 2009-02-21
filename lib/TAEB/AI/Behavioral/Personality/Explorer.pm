package TAEB::AI::Behavioral::Personality::Explorer;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Personality';

=head1 NAME

TAEB::AI::Behavioral::Personality::Explore - descend only after exploring the level

=cut

sub sort_behaviors {
    my $self = shift;
    my $config = TAEB->config->get_ai_config || {};
    my $fight = $config->{fight_behavior} || 'Melee';

    $self->prioritized_behaviors([
        "FixHunger",
        "Heal",
        "FixStatus",
        "Defend",
        "AttackSpell",
        "BuffSelf",
        "Chokepoint",
        "Kite",
        $fight,
        "Projectiles",
        "LetClose",
        "Vault",
        "Shop",
        "Carrion",
        "GetItems",
        "Equip",
        "Identify",
        "DipForExcalibur",
        "Wish",
        "BuyProtection",
        "Doors",
        "DeadEnd",
        "Explore",
        "CurseCheck",
        "Descend",
        "Search",
    ]);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

