package TAEB::AI::Behavioral::Personality::Explorer;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Personality';

=head1 NAME

TAEB::AI::Behavioral::Personality::Explore - descend only after exploring the level

=cut

sub sort_behaviors {
    my $self = shift;
    my $fight = TAEB->config->fight_behavior || 'Melee';

    $self->prioritized_behaviors([
        "FixHunger",
        "Heal",
        "FixStatus",
        "Defend",
        "AttackSpell",
        "BuffSelf",
        "Chokepoint",
        "Kite",
        "$fight",
        "Projectiles",
        "LetClose",
        "Vault",
        "Shop",
        "Carrion",
        "GetItems",
        "Identify",
        "DipForExcalibur",
        "Wish",
        "BuyProtection",
        "Doors",
        "DeadEnd",
        "Explore",
        #"PushBoulder",
        "CurseCheck",
        "Descend",
        "Search",
    ]);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

