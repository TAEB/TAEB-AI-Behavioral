package TAEB::AI::Behavioral::Personality;
use TAEB::OO;
use Time::HiRes qw/time/;
extends 'TAEB::AI';

=head1 NAME

TAEB::AI::Behavioral::Personality - base class for AIs with behaviors and personalities

=cut

has behaviors => (
    isa     => 'HashRef[TAEB::AI::Behavioral::Behavior]',
    lazy    => 1,
    default => sub {
        my $self      = shift;
        my $behaviors = {};

        if ($self->can('autoload_behaviors')) {
            for ($self->autoload_behaviors) {
                my $pkg = "TAEB::AI::Behavioral::Behavior::$_";

                (my $file = $pkg . '.pm') =~ s{::}{/}g;
                require $file;

                my $name = $pkg->name;

                $behaviors->{$name} = $pkg->new;
            }
        }

        return $behaviors;
    },
);

has prioritized_behaviors => (
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
);

sub add_behavior {
    my $self = shift;
    my $add = shift;
    my %args = @_;

    $self->prioritized_behaviors([
        map { exists $args{before} && $_ eq $args{before}
            ? ($add, $_)
            : exists $args{after}  && $_ eq $args{after}
            ? ($_, $add)
            : $_ } $self->prioritized_behaviors
    ]);
}

sub remove_behavior {
    my $self = shift;
    my $remove = shift;

    $self->prioritized_behaviors([
        grep { ref($remove) eq 'CODE' ? !$remove->($_) : $_ ne $remove }
             $self->prioritized_behaviors
    ]);
}

sub numeric_urgency {
    my $self = shift;
    my $urgency = shift;

    return 0 unless defined $urgency;

    my %urgencies = (
        critical    => 50,
        important   => 40,
        normal      => 30,
        unimportant => 20,
        fallback    => 10,
        none        => 0,
    );

    my $urg_val = $urgencies{$urgency};
    confess "$urgency is not an urgency" unless defined $urg_val;

    return $urg_val;
}

=head2 find_urgency Str -> Int

This will prepare the behavior and return its urgency.

=cut

sub find_urgency {
    my $self = shift;
    my $name = shift;

    my $behavior = $self->behaviors->{$name};
    $behavior->reset_urgency;
    my $time = time;
    $behavior->prepare;
    my $urgency  = $behavior->urgency || 'none';
    TAEB->log->personality(sprintf "The $name behavior has urgency $urgency. (%6gs)", time - $time);
    TAEB->log->personality("${behavior}'s urgencies method doesn't list $urgency", level => 'warning')
        unless exists $behavior->urgencies->{$urgency} || $urgency eq 'none';

    return $self->numeric_urgency($urgency);
}

=head2 max_urgency Str -> Int

This returns the maximum urgency that the given behavior can return.

=cut

sub max_urgency {
    my $self = shift;
    my $name = shift;

    my $behavior = $self->behaviors->{$name};
    return (reverse sort map { $self->numeric_urgency($_) }
                             keys %{ $behavior->urgencies })[0];
}

=head2 sort_behaviors -> None

Subclasses should override this to set the prioritized_behaviors attribute.

=cut

sub sort_behaviors {
    my $class = blessed($_[0]) || $_[0];
    TAEB->log->personality("$class must override sort_behaviors",
                           level => 'error');
}

=head2 next_behavior -> Behavior

This will prepare and weight all behaviors, returning a behavior with the
maximum urgency.

=cut

sub next_behavior {
    my $self = shift;

    $self->sort_behaviors;
    my @priority = $self->prioritized_behaviors;
    my $max_urgency = 0;
    my $max_behavior;

    my $time = time;
    # apply weights to urgencies, find maximum
    for my $behavior (@priority) {
        # if this behavior couldn't possibly beat the max, then stop early
        next if $max_urgency >= $self->max_urgency($behavior);

        my $urgency = $self->find_urgency($behavior);
        ($max_urgency, $max_behavior) = ($urgency, $behavior)
            if $urgency > $max_urgency;
    }

    return undef if $max_urgency <= 0;

    TAEB->log->personality(sprintf "Selecting behavior $max_behavior with urgency $max_urgency (%6gs).", time - $time);
    return $self->behaviors->{$max_behavior};
}

=head2 behavior_action [Behavior] -> Action

This will automatically do whatever bookkeeping is necessary to run the given
behavior. If no behavior is given, C<next_behavior> will be called.

=cut

sub behavior_action {
    my $self = shift;
    my $behavior = shift || $self->next_behavior;

    TAEB->log->personality("There was no behavior specified, and next_behavior gave no behavior (indicating no behavior with urgency above 0! I really don't know how to deal.", level => 'critical') if !$behavior;

    my $action = $behavior->action;
    $self->currently($behavior->name . ':' . $behavior->currently);
    return $action;
}

=head2 autoload_behaviors -> (Str)

Returns a list of behaviors that should be autoloaded. Defaults to the result of C<sort_behaviors>.

=cut

sub autoload_behaviors {
    my $self = shift;
    $self->sort_behaviors;
    return $self->prioritized_behaviors;
}

=head2 next_action -> Action

Defaults to just consulting the behaviors for action.

=cut

sub next_action {
    shift->behavior_action;
}

=head2 pickup Item -> Bool or Ref[Int]

Consult each behavior for what it should pick up.

=cut

sub pickup {
    my $self = shift;
    my $item = shift;

    my $final_pick = 0;

    for my $behavior (values %{ $self->behaviors }) {
        my $pick = $behavior->pickup($item);

        $pick = ref $pick ? $$pick : $pick ? 1e1000 : 0;

        if ($pick) {
            my $name = $behavior->name;
            TAEB->log->personality("$name wants to pick up $pick of $item");
            if (defined $item->price) {
                return 0 unless TAEB->gold >= $item->price;
            }

            $final_pick = $pick if $pick > $final_pick;
        }
    }

    return $final_pick >= $item->quantity ? 1 :
           $final_pick <= 0               ? 0 :
           \$final_pick;
}

=head2 drop Item -> Bool or Ref[Int]

Consult each behavior for what it should drop.

=cut

sub drop {
    my $self = shift;
    my $item = shift;
    my $should_drop = 0;

    for my $behavior (values %{ $self->behaviors }) {
        my $drop = $behavior->drop($item);

        # behavior is indifferent. Next!
        next if !defined($drop);

        TAEB->log->personality($behavior->name() . " wants to " .
            (!$drop ? "NOT drop " : ref $drop ? "drop $$drop of " : "drop ") .
            $item);

        # behavior does NOT want this item to be dropped
        return 0 if !$drop;

        # okay, something wants to get rid of it. if no other behavior objects,
        # it'll be dropped
        $drop = ref $drop ? $$drop : $drop ? 1e1000 : 0;
        $should_drop = $drop if $drop > $should_drop;
    }

    return $should_drop >= $item->quantity ? 1 :
           $should_drop <= 0 ? 0 :
           \$should_drop;
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

