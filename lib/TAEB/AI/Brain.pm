#!/usr/bin/env perl
package TAEB::AI::Brain;
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

TAEB::AI::Brain - how TAEB tactically extracts its amulets

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 next_action TAEB -> STRING

This is the method called by the main TAEB code to get individual commands.
It will be called with a C<$self> which will be your TAEB::AI::Brain object, and
a TAEB object for interacting with the rest of the system (such as for looking
at the map).

It should just return the string to send to NetHack.

Your subclass B<must> override this method.

=cut

sub next_action {
    die "You must override the 'next_action' method in TAEB::AI::Brain.";
}

=head2 institute

This is the method called when TAEB begins using this brain. This is guaranteed
to be called before any calls to next_action.

=cut

sub institute {
}

=head2 find_urgencies -> HashRef[Int]

This will prepare each behavior and return each's urgency.

=cut

sub find_urgencies {
    my $self = shift;
    my $urgencies = {};

    while (my ($name, $behavior) = each %{ $self->behaviors }) {
        $urgencies->{$name} = $behavior->prepare;
        TAEB->debug("The $name behavior has urgency $urgencies->{$name}.");
    }

    return $urgencies;
}

=head2 weight_behaviors -> HashRef[Int]

This will look through the brain's behaviors and return a hashref of their
relative weights. This calls C<weight_(behavior-name)> to discern this (or returns 100 if the method is unavailable). Subclasses should feel free to override this.

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

    my $urgencies = $self->find_urgencies;
    my $weights = $self->weight_behaviors;

    my ($max_urgency, $max_behavior);

    # apply weights to urgencies, find maximum
    for my $behavior (keys %$urgencies) {
        $urgencies->{$behavior} *= int($weights->{$behavior}/100)
            if defined $weights->{$behavior};
        ($max_behavior, $max_urgency) = ($behavior, $urgencies->{$behavior})
            if !defined($max_urgency) || $urgencies->{$behavior} > $max_urgency;
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

1;

