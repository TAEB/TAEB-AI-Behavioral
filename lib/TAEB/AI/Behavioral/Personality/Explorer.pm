package TAEB::AI::Behavioral::Personality::Explorer;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Personality';

=head1 NAME

TAEB::AI::Behavioral::Personality::Explore - descend only after exploring the level

=cut

sub sort_behaviors {
    my $self = shift;

    $self->prioritized_behaviors([
        "FixHunger",
        "Heal",
        "FixStatus",
        "Defend",
        "AttackSpell",
        "BuffSelf",
        "Kite",
        "Melee",
        "Projectiles",
        "Vault",
        "Shop",
        "Carrion",
        "GetItems",
        "Equip",
        "Identify",
        "DipForExcalibur",
        "Wish",
        "Potions",
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

1;

