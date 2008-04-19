#!/usr/bin/env perl
package TAEB::Spoilers::Combat;
use MooseX::Singleton;
use TAEB::Util 'dice';

# XXX: eventually all of these should be modified to possibly take into account
# the monster we're attacking, so we don't sit around whiffing at a shade and
# doing no damage

sub _barehanded_damage {
    my $self = shift;

    my $role = TAEB->role;
    my ($mindam, $avgdam, $maxdam);
    my $skill_bonus = 0;
    if ($role eq 'Mon' || $role eq 'Sam') {
        ($mindam, $avgdam, $maxdam) = dice 'd4';
        #$skill_bonus = TAEB->skill_level('martial arts');
    }
    else {
        ($mindam, $avgdam, $maxdam) = dice 'd2';
        #$skill_bonus = TAEB->skill_level('bare handed combat');
    }

    $avgdam += TAEB->strength_damage_bonus;
    $avgdam += TAEB->item_damage_bonus;

    $skill_bonus = int($skill_bonus * ($maxdam - 1) / 2);
    $avgdam += $mindam/$maxdam * $skill_bonus;

    return $avgdam;
}

sub _nonweapon_damage {
    my $self = shift;
    my $weapon = shift;

    # XXX: not exactly accurate, but eh
    return 0;
}

sub _artifact_damage {
    my $self = shift;
    my $weapon = shift;

    # XXX: fix this later
    return $self->_weapon_damage($weapon);
}

sub _weapon_damage {
    my $self = shift;
    my $weapon = shift;

    # arbitrary
    my $avgdam = dice(TAEB->z < 15 ? $weapon->sdam : $weapon->ldam);
    $avgdam += TAEB->strength_damage_bonus;
    $avgdam += TAEB->item_damage_bonus;

    # XXX: need to take into account things like enchantment, etc
    # XXX: important: need to get launcher *melee* damage, not ranged

    return $avgdam;
}

sub damage {
    my $self = shift;
    my $weapon = shift;
    if (!defined $weapon) {
        TAEB->error('tried to get damage statistics from an undef item');
        return 0;
    }

    my $type = blessed $weapon;
    if (!defined $type) {
        if (length $weapon == 1) {
            if ($weapon == '-') {
                return $self->_barehanded_damage;
            }
            else {
                $weapon = TAEB->inventory->get($weapon);
                $type = blessed $weapon;
            }
        }
        else {
            $weapon = TAEB->new_item($weapon);
            $type = blessed $weapon;
        }
    }

    if ($type eq 'TAEB::World::Item::Weapon') {
        if (TAEB::Spoilers::Item::Weapon->weapon($weapon)->{artifact}) {
            return $self->_artifact_damage($weapon);
        }
        else {
            return $self->_weapon_damage($weapon);
        }
    }
    elsif ($type eq 'TAEB::World::Item::Tool' &&
           TAEB::Spoilers::Item::Tool->tool($weapon)->{weaptool}) {
        return $self->_weapon_damage($weapon);
    }
    else {
        return $self->_nonweapon_damage($weapon);
    }
}

1;

