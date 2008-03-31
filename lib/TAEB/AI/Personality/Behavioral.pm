#!/usr/bin/env perl
package TAEB::AI::Personality::Behavioral;
use TAEB::OO;
extends 'TAEB::AI::Personality';

=head1 NAME

TAEB::AI::Personality::Behavioral - base class for personalities with behaviors

=cut

has behaviors => (
    isa     => 'HashRef[TAEB::AI::Behavior]',
    lazy    => 1,
    default => sub {
        my $self      = shift;
        my $behaviors = {};

        if ($self->can('autoload_behaviors')) {
            for ($self->autoload_behaviors) {
                my $pkg = "TAEB::AI::Behavior::$_";

                (my $file = $pkg . '.pm') =~ s{::}{/}g;
                require $file;

                my $name = $pkg->name;

                $behaviors->{$name} = $pkg->new;
            }
        }

        return $behaviors;
    },
);

=head2 find_urgency Str -> Int

This will prepare the behavior and return its urgency.

=cut

sub find_urgency {
    my $self = shift;
    my $name = shift;

    my $behavior = $self->behaviors->{$name};
    my $urgency  = $behavior->prepare;
    TAEB->debug("The $name behavior has urgency $urgency.");

    return $urgency;
}

=head2 weight_behaviors -> HashRef[Int]

This will look through the personality's behaviors and return a hashref of
their relative weights. This calls C<weight_(behavior-name)> to discern this
(or returns 100 if the method is unavailable). Subclasses should feel free to
override this.

=cut

sub weight_behaviors {
    my $self    = shift;
    my $results = {};

    for my $name (keys %{ $self->behaviors }) {
        my $behavior = $self->behaviors->{$name};
        my $method = "weight_$name";

        if ($self->can($method)) {
            $results->{$name} = $self->$method($behavior);
            TAEB->debug("The $name behavior has weight $results->{$name}.");
        }
        else {
            $results->{$name} = 100;
        }
    }

    return $results;
}

=head2 next_behavior -> Behavior

This will prepare and weight all behaviors, returning a behavior with the
maximum urgency.

=cut

sub next_behavior {
    my $self = shift;

    my $weights = $self->weight_behaviors;
    my $max_urgency = 0;
    my $max_behavior;

    # apply weights to urgencies, find maximum
    for my $behavior (sort {$weights->{$b} <=> $weights->{$a}} keys %$weights) {
        my $weight = $weights->{$behavior};

        # if this behavior couldn't possibly beat the max, then stop early
        last if $max_urgency > $weight * 100;

        my $urgency = $self->find_urgency($behavior) * $weight;
        ($max_urgency, $max_behavior) = ($urgency, $behavior)
            if $urgency > $max_urgency;
    }

    return undef if $max_urgency <= 0;

    TAEB->debug("Selecting behavior $max_behavior with urgency $max_urgency.");
    return $self->behaviors->{$max_behavior};
}

=head2 behavior_action [Behavior] -> Action

This will automatically do whatever bookkeeping is necessary to run the given
behavior. If no behavior is given, C<next_behavior> will be called.

=cut

sub behavior_action {
    my $self = shift;
    my $behavior = shift || $self->next_behavior;

    TAEB->critical("There was no behavior specified, and next_behavior gave no behavior (indicating no behavior with urgency above 0! I really don't know how to deal.") if !$behavior;

    my $action = $behavior->action;
    $self->currently($behavior->currently);
    return $action;
}

=head2 sort_behaviors -> HashRef[Int, Int, Int, Str]

This will prepare a report that tells you exactly how this personality
prioritizes all of its behaviors. This is used for answering the question, "Why
did TAEB do X instead of Y?"

The return value is a hashref of action names mapped to:

=over 4

=item Weighted urgency

=item Unweighted urgency (from behavior)

=item Weight multiplier (from personality)

=item Behavior name

=back

=cut

sub sort_behaviors {
    my $self = shift;
    my $weights = $self->weight_behaviors;
    my %action_weight;

    # apply weights to urgencies, find maximum
    for my $behavior (keys %$weights) {
        my $weight = $weights->{$behavior};
        my $possibilities = $self->behaviors->{$behavior}->urgencies;
        for my $urgency (keys %$possibilities) {
            my $action = $possibilities->{$urgency};
            my $weighted = $urgency * $weight;

            if (ref($action) ne 'ARRAY') {
                $action = [$action];
            }

            for (@$action) {
                $action_weight{$_} = [$weighted, $urgency, $weight, $behavior];
            }
        }
    }

    return \%action_weight;
}

=head2 autoload_behaviors -> (Str)

Returns a list of behaviors that should be autoloaded. Defaults to the keys
of C<weight_behaviors>.

=cut

sub autoload_behaviors {
    my $self = shift;
    keys %{ $self->weight_behaviors }
}

=head2 next_action -> Action

Defaults to just consulting the behaviors for action.

=cut

sub next_action {
    shift->behavior_action;
}

=head2 pickup Item -> Bool

Consult each behavior for what it should pick up.

=cut

sub pickup {
    my $self = shift;

    for my $behavior (values %{ $self->behaviors }) {
        return 1 if $behavior->pickup(@_);
    }

    return 0;
}

=head2 drop Item -> Bool

Consult each behavior for what it should drop.

=cut

sub drop {
    my $self = shift;
    my $should_drop = 0;

    for my $behavior (values %{ $self->behaviors }) {
        my $drop = $behavior->drop(@_);

        # behavior is indifferent. Next!
        next if !defined($drop);

        # behavior does NOT want this item to be dropped
        return 0 if !$drop;

        # okay, something wants to get rid of it. if no other behavior objects,
        # it'll be dropped
        $should_drop = 1;
    }

    return $should_drop;
}

=head2 send_message Str, *

This will send the message to itself and each of its behaviors.

=cut

sub send_message {
    my $self = shift;
    my $msgname = shift;

    for my $behavior (values %{ $self->behaviors }) {
        $behavior->$msgname(@_)
            if $behavior->can($msgname);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

