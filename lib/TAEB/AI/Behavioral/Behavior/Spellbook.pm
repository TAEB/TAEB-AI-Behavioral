package TAEB::AI::Behavioral::Behavior::Spellbook;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    my @items = grep { $self->pickup($_) && $_->difficult < TAEB->level } TAEB->inventory->items;
    return unless @items;

    my $item = shift @items;

    $self->currently("Reading a spellbook");
    $self->do(read => item => $item);
    $self->urgency('unimportant');
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 if $item->cost;
    return 0 unless $item->match(class => 'spellbook');
    return 1 if $item->match(identity => undef);
    return 0 if TAEB->knows_spell($item->spell);

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

