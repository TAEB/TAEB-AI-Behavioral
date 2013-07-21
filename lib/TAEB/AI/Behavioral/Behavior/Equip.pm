package TAEB::AI::Behavioral::Behavior::Equip;
use Moose;
use TAEB::OO;
use TAEB::Spoilers::Combat;
extends 'TAEB::AI::Behavioral::Behavior';

### Determination of items

sub _rate_armor {
    my $self = shift;
    my $item = shift;

    return 0 if !$item;

    # Monks don't wear body armor or shields
    if (TAEB->role eq 'Mon') {
        return -1 if $item->subtype eq 'shield'
                  || $item->subtype eq 'bodyarmor';
    }

    my $score = $item->ac || 0; # already includes enchantment

    $score++ if ($item->mc || 0) >= 2;

    # possibly cursed bad!
    my $cursed = $item->is_cursed;
    if (!defined($cursed)) {
        $score -= 3;

        # if we have an altar then we definitely want to check this out first
        $score -= 2 if TAEB->dungeon->has_tile_of_type('altar');
    }

    # cursed bad!!
    $score -= 5 if $item->is_cursed;

    # XXX: damage, resistances, weight?

    $score -= 20 if $item->match(identity => 'levitation boots');

    if ($item->has_tracker) {
        my $tracker = $item->tracker;
        $score++ if $tracker->includes_possibility('speed boots')
                 || $tracker->includes_possibility('gauntlets of power')
                 || $tracker->includes_possibility('cloak of magic resistance')
                 || $tracker->includes_possibility('helm of brilliance');
    }

    if (TAEB->ai->is_primary_spellcaster) {
        # We're trying to optimize for magical power, so don't wear
        # anything that interferes with magic.

        # No penalties for metal helms, as they protect us from falling
        # rocks o death

        $score-- if $item->match(identity => ['iron shoes', 'kicking boots']);

        $score -= 10 if $item->is_metallic;
        $score += 14 if $item->match(is_metallic => 1, subtype => 'helmet');

        $score -= 20 if $item->match(subtype => 'shield');
    }

    return $score;
}

sub _rate_ring {
    my ($self, $ring) = @_;

    return -1;
}

sub _rate_amulet {
    my ($self, $amulet) = @_;

    return -1;
}

sub _rate_blindfold {
    my ($self, $blindfold) = @_;

    return -1;
}

sub _rate_weapon {
    my ($self, $item) = @_;

    # Don't use anything that's not a weapon
    return -1 if $item->type ne 'weapon';

    # Monks use their fists
    return -1 if TAEB->role eq 'Mon';

    my $score = 1;

    # Don't use twohanders until I understand left hand pressure
    $score-- if $item->hands == 2;

    # Artifact weapons are nifty
    $score += 5 if $item->is_artifact;

    # Wizards should keep their quarterstaff
    $score += 2 if $item->name eq 'quarterstaff' && TAEB->role eq 'Wiz';

    # Anything else is decent
    return $score;
}

sub _rate_item {
    my ($self, $slot, $item) = @_;

    return 0 if (!$item);

    return $self->_rate_weapon($item)
        if $slot eq 'weapon' || $slot eq 'offhand';

    return $self->_rate_ring($item)
        if $slot eq 'left_ring' || $slot eq 'right_ring';

    return $self->_rate_amulet($item)
        if $slot eq 'amulet';

    return $self->_rate_blindfold($item)
        if $slot eq 'blindfold';

    return $self->_rate_armor($item);
}

sub best_item {
    my ($self, $slot) = @_;

    my $incumbent = TAEB->equipment->$slot;

    my $incumbent_score = $self->_rate_item($slot, $incumbent);

    my @candidates = TAEB->inventory->find(
        cost_each => 0,
    );

    my ($best_score, $best_item) = (0, undef);
    for my $item (@candidates) {
        # There are a lot of confusing issues surrounding the use
        # of the left hand - twohander, weapon and shield, or a
        # second weapon?  For now, always take the one-hander and
        # optional shield.
        next if $slot eq 'offhand';

        next if !$item->fits_in_slot($slot);

        # There are two ring slots; we put our best ring in the
        # right slot, because it's less likely to want swapping.
        # The right slot comes first in the inside-out ordering,
        # so it will be filled with the best item; we just have
        # to not reuse it here.

        next if $slot eq 'left_ring'
             && defined TAEB->equipment->right_ring
             && $item == TAEB->equipment->right_ring;

        my $rating = $self->_rate_item($slot, $item);

        ($best_score, $best_item) = ($rating, $item)
            if $rating > $best_score;
    }

    # Break ties in favor of the incumbent to avoid pointless swapping

    return $incumbent if $best_score == $incumbent_score;

    return $best_item;
}

### Implementation of changes

sub add_item {
    my ($self, $slot, $item) = @_;

    $self->currently("Equipping $item");
    $self->urgency("normal");

    if ($slot eq 'weapon') {
        $self->do(wield => weapon => $item);
    } else {
        $self->do(wear => item => $item, slot => $slot);
    }
}

sub remove_item {
    my ($self, $slot, $item, $goal) = @_;

    $self->currently("Removing $item" . (!$goal ? "" : " to equip $goal"));
    $self->urgency("normal");

    if ($slot eq 'weapon') {
        $self->do(wield => weapon => 'nothing');
    } else {
        $self->do(remove => item => $item);
    }
}

# The swap weapon slot is a bit weird, it doesn't have blockers
# as such but items can only be loaded in by first wielding them
sub handle_offhand {
    my ($self, $item) = @_;

    my $wep = TAEB->equipment->weapon;

    if (($wep || 0) == ($item || 0)) {
        $self->currently("Swapping " . ($item || "nothing") .
            " into the offhand slot");
        $self->do("swapweapons");
    } else {
        $self->currently("Wielding " . ($item || "nothing") .
            " in preparation to offhand it");
        $self->do(wield => weapon => ($item || "nothing"));
    }

    $self->urgency("normal");
}

# Should return true if an action was taken
sub implement {
    my ($self, $slot, $incumbent, $item) = @_;

    TAEB->log->ai("Trying to replace " . ($incumbent || "nothing") .
        " with " . ($item || "nothing"));

    # Easy :)
    return if (!defined($item) && !defined($incumbent))
           || (defined($item) && defined($incumbent) && $item == $incumbent);

    return if TAEB->equipment->under_cursed($slot);

    if ($slot eq "offhand") {
        $self->handle_offhand($item);
        return 1;
    } else {
        my ($bslot, $blocker);
        if (($bslot, $blocker) = TAEB->equipment->blockers($slot)) {
            $self->remove_item($bslot => $blocker, $item);
            return 1;
        }
    }

    if ($item) {
        $self->add_item($slot => $item);
        return 1;
    }

    # We only get here for weapons; armour blocks itself and is taken
    # off above.
    $self->remove_item($slot => $incumbent);
    return 1;
}

### Handling all slots

sub prepare {
    my $self = shift;

    SLOT: for my $slot (TAEB->equipment->slots_inside_out) {

        # Don't bother with the quiver as it's just a UI thing
        next if $slot eq 'quiver';

        my $incumbent = TAEB->equipment->$slot;
        my $new = $self->best_item($slot);

        last SLOT if $self->implement($slot, $incumbent => $new);
    }
}

use constant max_urgency => 'normal';

# Pick up items if they are better than something we have equipped
sub pickup {
    my $self = shift;
    my $item = shift;

    my @slots;

    if ($item->type eq 'weapon' || $item->type eq 'tool') {
        @slots = qw/weapon/; #TODO dualwield
    }

    if ($item->type eq 'armor') {
        @slots = $item->subtype;
    }

    if ($item->type eq 'ring') {
        @slots = qw/left_ring right_ring/;
    }

    if ($item->type eq 'amulet') {
        @slots = qw/amulet/;
    }

    for my $slot (@slots) {
        return 1 if $self->_rate_item($slot, $item) >
                    $self->_rate_item($slot, TAEB->equipment->$slot);
    }
}

__PACKAGE__->meta->make_immutable;

1;

