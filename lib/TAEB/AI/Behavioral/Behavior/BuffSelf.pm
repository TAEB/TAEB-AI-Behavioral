package TAEB::AI::Behavioral::Behavior::BuffSelf;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

# The basic premise of the new BuffSelf is "cast the best buff that
# you can afford to improve".  In combat we can afford anything if
# we have it, out of combat we can only afford things which cost
# 1/3 or less of our mp regen ... cumulative with lower priority
# things.

my @buff_options = (
    {
        buff => "very fast",
        have => sub { TAEB->senses->is_very_fast },
        with => sub {
            spell ("haste self", 60) || # XXX 90 if Skilled in escape
            potion("speed", 60, 90)
        },
    },
    # XXX galloping - only useful with riding + kiting
    # these require the framework to have a notion of see invisible
    #{
    #    buff => "invisible",
    #    have => sub { TAEB->senses->invisible },
    #    with => sub {
    #        spell ("invisibility", 38) ||
    #        potion("invisibility", 38, 10e9999)
    #    },
    #},
    #{
    #    buff => "see invisible",
    #    have => sub { TAEB->senses->see_invisible },
    #    with => sub {
    #        potion("see invisible", 800, 10e9999)
    #    },
    #},
    {
        buff => "protection",
        levels => 1,
        have => sub { TAEB->senses->spell_protection },
        with => sub {
            my $will_get = TAEB->senses->spell_protection_return;

            return if !$will_get;

            spell("protection", $will_get * 10) # XXX 20 if Expert
            # also the value of protecting varies a bit
        },
    },
    # XXX levitation - sometimes harmful
    # XXX detect monsters - would probably confuse TAEB too much
);

sub buff_options { @buff_options }

sub spell {
    my ($spell, $duration) = @_;

    $spell = TAEB->find_castable($spell);
    return unless defined $spell
               && $spell->fail < 50;

    return {
        action => [ cast => spell => $spell ],
        cost   => $spell->power,
        dur    => $duration,
    };
}

sub potion {
    my ($name, $duration, $blessed_duration) = @_;

    my $pot = TAEB->has_item(identity => "potion of $name", is_blessed => 1)
           || TAEB->has_item(identity => "potion of $name");

    return unless $pot;

    return {
        action => [ quaff => from => $pot ],
        cost   => 1000,
        dur    => $pot->is_blessed ? $blessed_duration : $duration,
    };
}

sub prepare {
    my $self = shift;

    # TODO actually implement permabuffing
    #
    # Interesting case: suppose we have Protection and Haste Self, but only
    # enough MP regen to keep one of them active.  We pick Haste Self.  Now
    # we put on speed boots; they don't identify since we are Very_fast, and
    # it seems exactly as if Haste Self never wore off.  How do we know to
    # start Protecting?
    return unless TAEB->current_level->has_enemies;

    for my $buff ($self->buff_options) {
        next if $buff->{have}->() && !$buff->{levels};

        my $imp = $buff->{with}->()
            or next;

        $self->do(@{$imp->{action}});
        $self->currently("Buffing $buff->{buff}");
        $self->urgency('normal');
        return;
    }
}

use constant max_urgency => 'normal';

sub pickup {
    my $self = shift;
    my $item = shift;

    # XXX find a better way to handle this
    # we need more information about the buffs than FixStatus uses...

    return 1 if $item->match(
        identity => [
            'potion of invisibility',
            'potion of speed',
            'potion of see invisible',
        ],
    );

    return;
}

__PACKAGE__->meta->make_immutable;

1;

