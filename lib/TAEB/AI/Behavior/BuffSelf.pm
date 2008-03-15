#!/usr/bin/env perl
package TAEB::AI::Behavior::BuffSelf;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub use_spells { ('protection', 'haste self') }

has buff_level => (
    isa     => 'HashRef[Int]',
    default => sub { {} },
);

sub prepare {
    my $self = shift;
    my ($max_spell, $max_priority) = (undef, 0);

    for ($self->use_spells) {
        my $spell = TAEB->find_castable($_)
            or next;
        my $priority = $self->buff_level->{$spell->name} ? 50 : 100;

        ($max_spell, $max_priority) = ($spell, $priority)
            if $priority > $max_priority;
    }

    return 0 if $max_priority == 0;

    $self->do(cast => spell => $max_spell);
    $self->currently("Casting ".($max_spell->name).".");
    return $max_priority;
}

sub urgencies {
    return {
       100 => "casting the first hit of a buff spell",
        50 => "casting a subsequent hit of a buff spell",
    },
}

sub msg_buff {
    my $self      = shift;
    my $spellname = shift;
    my $is_buffed = shift;
    my $delta     = shift;

    $self->buff_level->{$spellname} += $delta;
    if ($self->buff_level->{$spellname} xor $is_buffed) {
        $self->buff_level->{$spellname} = $is_buffed;
    }
}

make_immutable;
no Moose;

1;

