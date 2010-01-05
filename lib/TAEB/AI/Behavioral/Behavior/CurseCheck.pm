package TAEB::AI::Behavioral::Behavior::CurseCheck;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    # Can't see altar flash when blind
    return if TAEB->is_blind;

    my $level = TAEB->nearest_level(sub { shift->has_type('altar') })
        or return;

    my @drop = grep { $_->can_drop(ignore_is_worn => 1) }
               grep { !_item_under_cursed($_) }
               grep { $_->match(buc => undef) }
               TAEB->inventory;

    # No point in cursechecking no items
    return unless @drop;

    if (TAEB->current_tile->type eq 'altar') {
        my @need_to_remove = grep { !$_->can_drop }
                            @drop;

        if (@need_to_remove) {
            $self->remove_covers($need_to_remove[0])
                or die "We can't drop $need_to_remove[0], but nothing is stopping us?";
        } else {
            $self->currently("Dropping items for cursechecking.");
            $self->do(drop => items => \@drop);
        }

        $self->urgency('important');
        return;
    }

    # find an altar to cursecheck on
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'altar' },
        on_level => $level,
    );

    $self->if_path($path => "Heading towards an altar");
}

use constant max_urgency => 'important';

sub drop {
    my $self = shift;
    my $item = shift;

    return if TAEB->current_tile->type ne 'altar'
           || TAEB->is_blind
           || !$item->can_drop
           || $item->match('!buc' => undef)
           || $item->match(appearance => 'gold piece');

    TAEB->log->behavior("Yes, I want to drop $item because it needs to be cursechecked.");
    return 1;
}

# This should have been in NHI...
sub _item_to_slot {
    my $item = shift;

    my $slot;
    for (TAEB->equipment->slots) {
        $slot = $_ if TAEB->equipment->$_ && TAEB->equipment->$_ == $item;
    }

    return $slot;
}

sub _item_under_cursed {
    my $item = shift;

    my $slot = _item_to_slot($item);

    return $slot && TAEB->equipment->under_cursed($slot);
}

# XXX: this is an disgusting hack
sub remove_covers {
    my ($self, $item) = @_;

    my $slot = _item_to_slot($item);
    return unless $slot;

    my $blocking_item = TAEB->equipment->blockers($slot);
    return unless $blocking_item;

    $self->currently("Removing $blocking_item so we can check $item");
    $self->do(remove => item => $blocking_item);
    return 1;
}


# XXX: this does nothing yet, tis a sketch
sub veto_wear {
    my $self   = shift;
    my $action = shift;

    return 0 unless TAEB->current_tile->type eq 'altar';
    return 0 if defined $action->item->buc;
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;

