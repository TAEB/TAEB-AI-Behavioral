package TAEB::AI::Behavioral::Behavior::IdentifyRing;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    return if TAEB->is_blind;

    my @items = grep { $self->pickup($_) } TAEB->inventory->items;
    return unless @items;

    my $level = TAEB->nearest_level(sub { shift->has_type('sink') })
        or return;

    # are we standing on a sink? if so, drop!
    if (TAEB->current_tile->type eq 'sink') {
        $self->currently("Dropping the ring in the sink");
        $self->do(drop => items => \@items);
        $self->urgency('unimportant');
        return;
    }

    # find a sink
    my $path = TAEB::World::Path->first_match(
        sub { shift->type eq 'sink' },
        on_level => $level,
        why => "IdentifyRing",
    );

    $self->if_path($path => "Heading towards a sink");
}

# collect unknown rings
sub pickup {
    my $self = shift;
    my $item = shift;

    # we only care about unidentified stuff and rings
    return 0 unless $item->match(identity => undef, class => 'ring');

    return 1;
}

sub drop {
    my $self = shift;
    my $item = shift;

    return unless $item->match(class => 'ring', identity => undef);

    return if TAEB->current_tile->type ne 'sink'
           || TAEB->is_blind;

    TAEB->log->behavior("Yes, I want to drop $item because I want to find out what it is.");
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

