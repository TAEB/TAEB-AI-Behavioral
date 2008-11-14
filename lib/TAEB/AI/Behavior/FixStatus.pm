#!/usr/bin/env perl
package TAEB::AI::Behavior::FixStatus;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

my @can_fix = (
    "unicorn horn" => {
        refine    => { not_buc => 'cursed' },
        statuses  => [qw/blind stun conf hallu sick/],
        priority  => 100,
        action    => 'apply',
        args      => sub { item => shift },
        currently => sub { "Rubbing " . shift },
        reuseable => 1,
    },
    "carrot" => {
        status    => 'blind',
        priority  => 80,
        action    => 'eat',
        args      => sub { item => shift },
    },
    "sprig of wolfsbane" => {
        status    => 'lycanthropy',
        priority  => 80,
        action    => 'eat',
        args      => sub { item => shift },
    },
    "holy water" => {
        status    => 'lycanthropy',
        priority  => 80,
        action    => 'quaff',
        args      => sub { item => shift },
    },
);

my %restable = (blind => 1, stun => 1, conf => 1, hallu => 1);

sub prepare {
    my $self = shift;

    if (TAEB->is_petrifying) {
        if (my $lizard = TAEB->find_item('lizard corpse')) {
            $self->do(eat => item => $lizard);
            $self->currently("Eating lizard to fix petrification");
        }
        elsif (TAEB->can_pray) {
            $self->do('pray');
            $self->currently("Praying to fix petrification");
        }
        return 100;
    }

    my %c;
    $c{blind}       = TAEB->is_blind;
    $c{stun}        = TAEB->is_stunned;
    $c{sick}        = TAEB->is_sick;
    $c{conf}        = TAEB->is_confused;
    $c{hallu}       = TAEB->is_hallucinating;
    $c{lycanthropy} = TAEB->is_lycanthropic;

    for (my $i = 0; $i < @can_fix; $i += 2) {
        my ($item_name, $fix) = @can_fix[$i, $i+1];

        my @statuses = @{ $fix->{statuses} || [$fix->{status}] };
        my @have = grep { $c{$_} } @statuses
            or next;

        my %match = (identity => $item_name);
        %match = (%match, %{ $fix->{refine} }) if $fix->{refine};
        my $item = TAEB->find_item(%match);
        next unless $item;

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

    if (grep { $restable{$_} && $c{$_} } keys %c) {
        $self->do('search');
        return 5;
    }

    return 0;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    for (my $i = 0; $i < @can_fix; $i += 2) {
        my ($item_name, $fix) = @can_fix[$i, $i+1];
        if ($fix->{reusable}) {
            my %match = (identity => $item->identity);
            %match = (%match, %{ $fix->{refine} }) if $fix->{refine};
            next if TAEB->find_item(%match);
        }
        return 1 if $item->match(identity => $item_name);
    }

    return;
}

sub urgencies {
    return {
       100 => "using a unicorn horn to fix status effects",
        80 => "using items to fix status effects",
         5 => "waiting off a status effect",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

