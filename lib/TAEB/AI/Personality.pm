#!/usr/bin/env perl
package TAEB::AI::Personality;
use Moose;

has currently => (
    is => 'rw',
    isa => 'Str',
    default => "?",
    trigger => sub {
        my ($self, $currently) = @_;
        TAEB->info("Currently: $currently.") unless $currently eq '?';
    },
);

has path => (
    is => 'rw',
    isa => 'TAEB::World::Path',
    trigger => sub {
        my ($self, $path) = @_;
        TAEB->info("Current path: @{[$path->path]}.") if $path;
    },
);

has behaviors => (
    is      => 'rw',
    isa     => 'HashRef[TAEB::AI::Behavior]',
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

=head1 NAME

TAEB::AI::Personality - how TAEB tactically extracts its amulets

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 next_action TAEB -> STRING

This is the method called by the main TAEB code to get individual commands. It
will be called with a C<$self> which will be your TAEB::AI::Personality object,
and a TAEB object for interacting with the rest of the system (such as for
looking at the map).

It should just return the string to send to NetHack.

Your subclass B<must> override this method.

=cut

sub next_action {
    die "You must override the 'next_action' method in TAEB::AI::Personality.";
}

=head2 institute

This is the method called when TAEB begins using this personality. This is
guaranteed to be called before any calls to next_action.

=cut

sub institute {
}

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

    while (my ($name, $behavior) = each %{ $self->behaviors }) {
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

=head2 behavior_action [Behavior] -> Str

This will automatically do whatever bookkeeping is necessary to run the given
behavior. If no behavior is given, C<next_behavior> will be called.

=cut

sub behavior_action {
    my $self = shift;
    my $behavior = shift || $self->next_behavior;

    TAEB->critical("There was no behavior specified, and next_behavior gave no behavior (indicating no behavior with urgency above 0! I really don't know how to deal.") if !$behavior;

    my $action = $behavior->next_action;
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
    while (my ($behavior, $weight) = each %$weights) {
        my $possibilities = $self->behaviors->{$behavior}->weights;
        while (my ($urgency, $action) = each %$possibilities) {
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

1;

