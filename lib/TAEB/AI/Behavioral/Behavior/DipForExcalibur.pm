package TAEB::AI::Behavioral::Behavior::DipForExcalibur;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub can_make_excalibur {
    return unless TAEB->align eq 'Law';

    # only one Excalibur. Alas.
    return if TAEB->seen_artifact("Excalibur");

    return 1;
}

sub prepare {
    my $self = shift;

    return unless $self->can_make_excalibur;

    # are we eligible to dip for Excalibur now?
    return unless TAEB->level >= 5;

    # need to stop levitating first..
    return if TAEB->is_levitating;

    my $longsword = TAEB->has_item("long sword")
        or return;

    my $level = TAEB->nearest_level(sub {
        my $lvl = shift;
        return 0 if $lvl->is_minetown;
        return $lvl->has_type('fountain');
    });

    return if !$level;

    unless (TAEB->current_level->is_minetown) {
        # are we standing on a fountain? if so, dip!
        if (TAEB->current_tile->type eq 'fountain') {
            $self->currently("Dipping for Excalibur!");
            $self->do(dip => item => $longsword, into => "fountain");
            $self->urgency('unimportant');
            return;
        }
    }

    # find a fountain
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'fountain' },
        on_level => $level,
    );

    $self->if_path($path => "Heading towards a fountain");
}

use constant max_urgency => 'unimportant';

sub pickup {
    my $self = shift;
    my $item = shift;

    if ($item->match(identity => 'long sword')) {
        return unless $self->can_make_excalibur;
        return if TAEB->has_item("long sword");
        return 1;
    }
}

__PACKAGE__->meta->make_immutable;

1;

