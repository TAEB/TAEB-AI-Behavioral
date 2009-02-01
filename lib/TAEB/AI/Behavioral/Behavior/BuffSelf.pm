package TAEB::AI::Behavioral::Behavior::BuffSelf;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub use_spells { ('protection', 'haste self') }

has buff_level => (
    isa     => 'HashRef[Int]',
    default => sub { {} },
);

sub prepare {
    my $self = shift;
    my ($max_spell, $max_urgency) = (undef, 0);

    return unless TAEB->current_level->has_enemies;

    for ($self->use_spells) {
        my $spell = TAEB->find_castable($_)
            or next;
        my $urgency = $self->buff_level->{$spell->name} ? 'fallback'
                                                        : 'unimportant';

        ($max_spell, $max_urgency) = ($spell, $urgency)
            if $self->numeric_urgency($urgency) >
               $self->numeric_urgency($max_urgency);
    }

    return if $max_urgency == 0;

    $self->do(cast => spell => $max_spell);
    $self->currently("Casting ".($max_spell->name).".");
    $self->urgency($max_urgency);
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

__PACKAGE__->meta->make_immutable;
no Moose;

1;

