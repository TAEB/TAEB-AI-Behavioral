package TAEB::AI::Behavioral::Personality;
use Moose;
use TAEB::OO;
use Time::HiRes qw/time/;
extends 'TAEB::AI';

use TAEB::Util qw/:colors display refaddr/;

use TAEB::AI::Behavioral::ThreatEvaluation;

=head1 NAME

TAEB::AI::Behavioral::Personality - base class for AIs with behaviors and personalities

=cut

with (
    'TAEB::AI::Role::Action::Backoff' => {
        action        => 'TAEB::Action::Travel',
        blackout_when => sub {
            my ($self, $prev_action) = @_;

            return TAEB->current_tile == $prev_action->starting_tile;
        },
        clear_when    => sub {
            my ($self, $prev_action) = @_;
            my $original_path = $prev_action->intralevel_subpath || $prev_action->path;
            return TAEB->current_tile == $original_path->to;
        },
    },

    'TAEB::AI::Role::Action::Backoff' => {
        action        => 'TAEB::Action::Ascend',
        blackout_when => sub {
            my ($self, $prev_action) = @_;

            return TAEB->current_tile == $prev_action->starting_tile;
        },
        clear_when    => sub {
            my ($self, $prev_action) = @_;

            return TAEB->current_level->z < $prev_action->starting_tile->z;
        },
    },
);

has behavior => (
    is        => 'rw',
    isa       => 'TAEB::AI::Behavioral::Behavior',
    predicate => 'has_behavior',
);

has behaviors => (
    traits    => ['Hash'],
    isa       => 'HashRef[TAEB::AI::Behavioral::Behavior]',
    lazy      => 1,
    handles => {
        behaviors        => 'values',
        get_behavior     => 'get',
        _set_behavior    => 'set',
        _delete_behavior => 'delete',
    },
    default   => sub {
        my $self = shift;
        $self->sort_behaviors;
        my %behaviors = map {
            $_ => $self->_instantiate_behavior($_)
        } $self->prioritized_behaviors;
        return \%behaviors;
    },
);

has prioritized_behaviors => (
    traits    => ['Array'],
    writer    => '_set_prioritized_behaviors',
    isa       => 'ArrayRef[Str]',
    predicate => 'has_prioritized_behaviors',
    handles   => {
        prioritized_behaviors => 'elements',
    },
);

around prioritized_behaviors => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig unless @_;
    return $self->_set_prioritized_behaviors(@_);
};

sub _instantiate_behavior {
    my $self = shift;
    my $name = shift;

    my $class = "TAEB::AI::Behavioral::Behavior::$name";
    return $class->new(personality => $self);
}

sub add_behavior {
    my $self = shift;
    my $add = shift;
    my %args = @_;

    $self->_set_behavior($add => $self->_instantiate_behavior($add));
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

    $self->_delete_behavior($remove);
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
    my $limit = shift;

    my $behavior = $self->get_behavior($name)
        or do {
            TAEB->log->ai("The '$name' behavior may have disappeared.", level => "info");
            return $self->numeric_urgency('none');
        };

    $behavior->reset_urgency;
    if ($self->numeric_urgency($behavior->max_urgency) <= $limit) {
        TAEB->log->ai("The $name behavior is skipped, urgency <= $limit");
        return $self->numeric_urgency('none');
    }
    my $time = time;
    $behavior->prepare;
    my $urgency  = $behavior->urgency || 'none';
    TAEB->log->ai(sprintf "The $name behavior has urgency $urgency. (%6gs)", time - $time);

    return $self->numeric_urgency($urgency);
}

=head2 sort_behaviors -> None

Subclasses should override this to set the prioritized_behaviors attribute.

=cut

sub sort_behaviors {
    my $class = blessed($_[0]) || $_[0];
    TAEB->log->ai("$class must override sort_behaviors", level => 'error');
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
        my $urgency = $self->find_urgency($behavior, $max_urgency);
        ($max_urgency, $max_behavior) = ($urgency, $behavior)
            if $urgency > $max_urgency;
    }

    return if $max_urgency <= 0;

    TAEB->log->ai(sprintf "Selecting behavior $max_behavior with urgency $max_urgency (%6gs).", time - $time);
    return $self->get_behavior($max_behavior);
}

=head2 next_action -> Action

This will automatically do whatever bookkeeping is necessary to choose and run
a behavior.

=cut

sub next_action {
    my $self = shift;

    $self->behavior->done
        if $self->has_behavior;

    my $behavior = $self->next_behavior;

    TAEB->log->ai("There was no behavior specified, and next_behavior gave no behavior (indicating no behavior with urgency above 0! I really don't know how to deal.", level => 'critical') if !$behavior;

    $self->behavior($behavior);

    my $action = $behavior->action;

    $self->currently($behavior->name . ':' . $behavior->currently);

    return $action;
}

=head2 pickup Item -> Bool or Ref[Int]

Consult each behavior for what it should pick up.

=cut

sub pickup {
    my $self = shift;
    my $item = shift;

    my $final_pick = 0;

    for my $behavior ($self->behaviors) {
        my $pick = $behavior->pickup($item);

        $pick = ref $pick ? $$pick : $pick ? 1e1000 : 0;

        if ($pick) {
            my $name = $behavior->name;
            TAEB->log->ai("$name wants to pick up $pick of $item");
            if (defined $item->cost) {
                return 0 unless TAEB->gold >= $item->cost;
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

    for my $behavior ($self->behaviors) {
        my $drop = $behavior->drop($item);

        # behavior is indifferent. Next!
        next if !defined($drop);

        TAEB->log->ai($behavior->name . " wants to " .
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

sub respond_genocide_species { "soldier ant\n" }

sub respond_genocide_class { "a\n" }

=head2 evaluate_threat TAEB::World::Monster -> TAEB::AI::Behavioral::ThreatEvaluation

Evaluates the threat level of a monster, to be used by several behaviors, in general boolean comparative terms.  Should depend on TAEB's power and may depend on the monster's state.

=cut

# This is a prime candidate for memoization

sub evaluate_threat {
    my ($self, $monster) = @_;

    my %p;

    my $avg_damage = $monster->average_melee_damage;
    my $max_damage = $monster->maximum_melee_damage;

    # We will avoid melee at most any cost against things that _can_
    # onehit us, also item-stealers

    # Possibly worth considering spellcasters here, but we don't
    # track MR anyway

    # Should we avoid foocubi too?  They're a bit harder to recognize,
    # and they don't _steal_ anything (that we use)

    $p{avoid_melee} = 1 if $monster->is_nymph;
    $p{avoid_melee} = 1 if $max_damage >= TAEB->hp;

    # Estimate how long it would take for the monster to kill us

    my $turns = $avg_damage * $monster->speed / (TAEB->speed * TAEB->hp);

    $p{spend_minor} = 1 if $turns < 20;
    $p{spend_major} = 1 if $turns < 10;

    return TAEB::AI::Behavioral::ThreatEvaluation->new(%p);
}

=head2 is_primary_spellcaster

Should we optimize for magical or physical power?  What we actually
use for attack depends on our actual ability, this needs to estimate
our potential.

=cut

sub is_primary_spellcaster {
    # For now, only wizards are played like this

    TAEB->role eq "Wiz"
}

do {
    my %goal_colors;

    sub _onframe_goals {
        my $self = TAEB->ai;
        return unless $self->has_prioritized_behaviors;

        %goal_colors = ();

        my @paths;

        for my $name ($self->prioritized_behaviors) {
            my $behavior = $self->get_behavior($name);
            if (!$behavior) {
                confess "No behavior with name $behavior!";
            }

            next unless $behavior->urgency
                     && $behavior->urgency ne 'none';

            next unless $behavior->action
                     && $behavior->action->can('path');

            my $path = $behavior->action->path or next;

            push @paths, [ $self->numeric_urgency($behavior->urgency), $path ];
        }

        @paths = sort { $b->[0] <=> $a->[0] } @paths;

        my @colors = (
            COLOR_BLUE, COLOR_CYAN, COLOR_GREEN,
            COLOR_BROWN, COLOR_RED, COLOR_MAGENTA,
        );

        for (@paths) {
            my $dcolor = display(shift @colors or last);

            for my $reftile (keys %{ $_->[1]->tiles }) {
                $goal_colors{$reftile} ||= $dcolor;
            }
        }
    }

    sub drawing_modes {
        goals => {
            description => "Show highest-priority goals",
            color => sub {
                $goal_colors{refaddr shift} || display(COLOR_GRAY)
            },
            onframe => \&_onframe_goals,
        }
    }
};

use Module::Pluggable (
    require          => 1,
    sub_name         => 'load_behaviors',
    search_path      => ['TAEB::AI::Behavioral::Behavior'],
    on_require_error => sub { confess "Couldn't require $_[0]: $_[1]" },
);

load_behaviors();

__PACKAGE__->meta->make_immutable;

1;

