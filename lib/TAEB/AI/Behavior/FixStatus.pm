#!/usr/bin/env perl
package TAEB::AI::Behavior::FixStatus;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

my @can_fix = (
    "unicorn horn" => {
        statuses  => [qw/blind stun conf hallu/],
        priority  => 100,
        action    => 'apply',
        args      => sub { item => shift },
        currently => sub { "Rubbing " . shift },
    },
    "carrot" => {
        status    => 'blind',
        priority  => 80,
        action    => 'eat',
        args      => sub { food => shift },
    },
    "sprig of wolfsbane" => {
        status    => 'lycanthropy',
        priority  => 80,
        action    => 'eat',
        args      => sub { food => shift },
    },
    "holy water" => {
        status    => 'lycanthropy',
        priority  => 80,
        action    => 'quaff',
        args      => sub { item => shift },
    },
);

sub prepare {
    my $self = shift;

    my %c;
    $c{blind}       = TAEB->senses->is_blind;
    $c{stun}        = TAEB->senses->is_stunned;
    $c{conf}        = TAEB->senses->is_confused;
    $c{hallu}       = TAEB->senses->is_hallucinating;
    $c{lycanthropy} = TAEB->senses->is_lycanthropic;

    for (my $i = 0; $i < @can_fix; $i += 2) {
        my ($item_name, $fix) = @can_fix[$i, $i+1];

        my @statuses = @{ $fix->{statuses} || [$fix->{status}] };
        my @have = grep { $c{$_} } @statuses
            or next;

        my $item = TAEB->find_item($item_name)
            or next;

        my $currently;

        if (ref($fix->{currently}) eq 'CODE') {
            $currently = $fix->{currently}->($item);
        }
        elsif ($fix->{currently}) {
            $currently = $fix->{currently};
        }
        else {
            $currently = ucfirst($fix->{action}) . " a $item";
        }

        $currently .= " to fix: " . join ', ', @have;

        $self->do($fix->{action}, $fix->{args}->($item));
        $self->currently($currently);

        return $fix->{priority};
    }

    return 0;
}

sub urgencies {
    return {
       100 => "using a unicorn horn to fix status effects",
        80 => "using items to fix status effects",
    },
}

1;

