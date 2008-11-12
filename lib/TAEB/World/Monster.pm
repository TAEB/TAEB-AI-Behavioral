#!/usr/bin/env perl
package TAEB::World::Monster;
use TAEB::OO;
use TAEB::Util qw/:colors/;

use overload %TAEB::Meta::Overload::default;

has glyph => (
    isa      => 'Str',
    required => 1,
);

has color => (
    isa      => 'Str',
    required => 1,
);

has tile => (
    isa      => 'TAEB::World::Tile',
    weak_ref => 1,
    handles  => [qw/x y z level in_shop in_temple/],
);

sub is_shk {
    my $self = shift;

    # if we've seen a nurse recently, then this monster is probably that nurse
    # we really need proper monster tracking! :)
    return 0 if TAEB->turn < (TAEB->last_seen_nurse || -100) + 3;

    return 0 unless $self->glyph eq '@' && $self->color eq COLOR_WHITE;

    # a shk isn't a shk if it's outside of its shop!
    # this also catches angry shks, but that's not too big of a deal
    return 0 unless $self->tile->type eq 'obscured'
                 || $self->tile->type eq 'floor';
    return $self->in_shop ? 1 : undef;
}

sub is_priest {
    my $self = shift;
    return 0 if !($self->glyph eq '@' && $self->color eq COLOR_WHITE);
    return ($self->in_temple ? 1 : undef);
}

sub is_oracle {
    my $self = shift;
    return 0 if TAEB->z < 5 || TAEB->z > 9;
    return 0 unless $self->x == 39 && $self->y == 12;
    return 1 if $self->glyph eq '@' && $self->color eq COLOR_BRIGHT_BLUE;
    return 0;
}

sub is_vault_guard {
    my $self = shift;
    return 0 unless TAEB->following_vault_guard;
    return 1 if $self->glyph eq '@' && $self->color eq COLOR_BLUE;
    return 0;
}

sub is_quest_friendly {
    my $self = shift;

    # Attacking @s in quest level 1 will screw up your quest. So...don't.
    return 1 if TAEB->current_level->known_branch
             && TAEB->current_level->branch eq 'quest'
             && TAEB->z == 1
             && $self->glyph eq '@';
    return 0;
}

sub is_enemy {
    my $self = shift;
    return 0 if $self->is_oracle;
    return 0 if $self->is_coaligned_unicorn;
    return 0 if $self->is_vault_guard;
    return 0 if $self->is_peaceful_watchman;
    return 0 if $self->is_quest_friendly;
    return undef unless (defined $self->is_shk || defined $self->is_priest);
    return 0 if $self->is_shk;
    return 0 if $self->is_priest;
    return 1;
}

sub is_meleeable {
    my $self = shift;

    return 0 unless $self->is_enemy;

    # floating eye (paralysis)
    return 0 if $self->color eq COLOR_BLUE
             && $self->glyph eq 'e';

    # blue jelly (cold)
    return 0 if $self->color eq COLOR_BLUE
             && $self->glyph eq 'j'
             && !TAEB->cold_resistant;

    # spotted jelly (acid)
    return 0 if $self->color eq COLOR_GREEN
             && $self->glyph eq 'j';

    # gelatinous cube (paralysis)
    return 0 if $self->color eq COLOR_CYAN
             && $self->glyph eq 'b';

    return 1;
}

# Yes, I know the name is long, but I couldn't think of anything better.
#  -Sebbe.
sub is_seen_through_warning {
    my $self = shift;
    return $self->glyph =~ /[1-5]/;
}

sub is_sleepable {
    my $self = shift;
    return $self->is_meleeable;
}

sub respects_elbereth {
    my $self = shift;

    return 0 if $self->glyph =~ /[A@]/;
    return 0 if $self->is_minotaur;
    # return 0 if $self->is_rider;
    # return 0 if $self->is_blind && !$self->is_permanently_blind;

    return 1;
}

sub is_minotaur {
    my $self = shift;
    $self->glyph eq 'H' && $self->color eq COLOR_BROWN
}

sub is_coaligned_unicorn {
    my $self = shift;
    return 0 if $self->glyph ne 'u';
    return 0 if $self->color eq COLOR_BROWN;

    # this is coded somewhat strangely to deal with black unicorns being
    # blue or dark gray
    if ($self->color eq COLOR_WHITE) {
        return TAEB->align eq 'Law';
    }

    if ($self->color eq COLOR_GRAY) {
        return TAEB->align eq 'Neu';
    }

    return TAEB->align eq 'Cha';
}

sub is_peaceful_watchman {
    my $self = shift;
    return 0 unless $self->level->is_minetown;
    return 0 if $self->level->angry_watch;
    return 0 unless $self->glyph eq '@';

    return $self->color eq COLOR_GRAY || $self->color eq COLOR_GREEN;
}

sub is_ghost {
    my $self = shift;

    return $self->glyph eq ' ' if $self->level->is_rogue;
    return $self->glyph eq 'X';
}

sub can_move {
    my $self = shift;
    # spotted jelly, blue jelly
    return 0 if $self->glyph eq 'j' && ($self->color eq COLOR_GREEN  ||
                                        $self->color eq COLOR_BLUE);
    # brown yellow green red mold
    return 0 if $self->glyph eq 'F' && ($self->color eq COLOR_BROWN  ||
                                        $self->color eq COLOR_YELLOW ||
                                        $self->color eq COLOR_GREEN  ||
                                        $self->color eq COLOR_RED);
    return 0 if $self->is_oracle;
    return 1;
}

sub debug_line {
    my $self = shift;
    my @bits;

    push @bits, sprintf '(%d,%d)', $self->x, $self->y;
    push @bits, 'g<' . $self->glyph . '>';
    push @bits, 'c<' . $self->color . '>';

    return join ' ', @bits;
}

# all monsters are in LOS because we only keep track of monsters in LOS
sub in_los { return 1 }

=head2 spoiler :: hash

Returns the monster spoiler (L<TAEB::Spoiler::Monster>) entry for this thing,
or undef if the symbol does not uniquely determine the monster.

=cut

sub spoiler {
    my $self = shift;

    my @candidates = TAEB::Spoilers::Monster->search(glyph => $self->glyph,
        color => $self->color);

    return undef if @candidates > 2;
    return $candidates[1];
}

=head2 can_be_outrun :: bool

Return true if the player can definitely outrun the monster.

=cut

sub can_be_outrun {
    my $self = shift;

    my $spoiler = $self->spoiler || return 0;
    my $spd = $spoiler->{speed};
    my ($pmin, $pmax) = TAEB->senses->speed;

    return $spd < $pmin || $spd == $pmin && $spd < $pmax;
}

=head2 should_attack_at_range :: Bool

Returns true if the monster is (probably) dangerous in melee to the point
where wand charges and kiting are preferable.

=cut

sub should_attack_at_range {
    my $self = shift;

    return 1 if $self->glyph eq 'n';
    return 1 if $self->is_minotaur;

    # add other things as they become a problem / replace with better spoiler
    # handling...

    return 0;
}

=head2 can_be_infraseen :: Bool

Returns true if the player could see this monster using infravision.

=cut

sub can_be_infraseen {
    my $self = shift;

    return TAEB->senses->has_infravision && $self->glyph !~
        /[abceijmpstvwyDEFLMNPSWXZ';:~]/; # evil evil should be in T:M:S XXX
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

