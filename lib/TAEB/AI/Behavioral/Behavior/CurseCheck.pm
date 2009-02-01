package TAEB::AI::Behavioral::Behavior::CurseCheck;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    # Can't see altar flash when blind
    return if TAEB->is_blind;

    my $level = TAEB->nearest_level(sub { shift->has_type('altar') })
        or return;

    my @drop = grep { $_->can_drop && $_->match(buc => undef) }
               TAEB->inventory->items;

    # No point in cursechecking no items
    return unless @drop;

    if (TAEB->current_tile->type eq 'altar') {
        $self->currently("Dropping items for cursechecking.");
        $self->do(drop => items => \@drop);
        $self->urgency('unimportant');
        return;
    }

    # find an altar to cursecheck on
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'altar' },
        on_level => $level,
        why => "Curse-check",
    );

    $self->if_path($path => "Heading towards an altar");
}

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

__PACKAGE__->meta->make_immutable;
no Moose;

1;

