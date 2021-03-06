package TAEB::AI::Behavioral::Behavior;
use Moose;
use TAEB::OO;
use TAEB::AI::Behavioral::Meta::Types;

has personality => (
    is       => 'ro',
    isa      => 'TAEB::AI::Behavioral::Personality',
    required => 1,
    weak_ref => 1,
    handles  => [
        'travel_is_blacked_out',
        'ascend_is_blacked_out',
        'fully_explored',
        'set_fully_explored',
        'clear_fully_explored',
        'locktool',
    ],
);

has currently => (
    is  => 'rw',
    isa => 'Str',
);

has _action => (
    is  => 'rw',
    isa => 'ArrayRef',
);

has urgency => (
    is      => 'rw',
    isa     => 'TAEB::Type::Urgency',
    clearer => 'reset_urgency',
);

=head2 prepare -> None

This should do any preparation required for the action it's going to take.
This includes things like pathfinding for Explore.

=cut

sub prepare { }

=head2 max_urgency -> TAEB::Type::Urgency

This should return the highest urgency the behavior can have.
This is used to quickly cull behaviors when a more urgent one has been found.

=cut

sub max_urgency { 'critical' }

=head2 do Str, Args

This will defer creation an Action of the given name, initialized with the
given arguments.

Once L</action> is called, the action will be instantiated.

=cut

sub do { ## no critic (ProhibitBuiltinHomonyms)
    my $self = shift;

    $self->_action([@_]);
}

=head2 action

Creates the action using the cached arguments.

=cut

sub action {
    my $self = shift;

    my $action_arguments = $self->_action;

    return TAEB::Action->new_action(@$action_arguments);
}

=head2 name -> Str

The name of the behavior. This should not be overridden.

=cut

sub name {
    my $self = shift;
    my $pkg = blessed($self) || $self;
    $pkg =~ s/^TAEB::AI::Behavioral::Behavior:://;
    return $pkg;
}

=head2 write_elbereth add_engraving => 1, method => 'dust' | 'best'

This will do the best it can to write an Elbereth.

Just call it instead of C<< $self->commands >> and C<< $self->currently >>.

=cut

sub write_elbereth {
    my $self = shift;
    my %args = (
        method        => 'dust',
        add_engraving => 1,
        @_,
    );

    $self->currently("Writing Elbereth.");

    my $item;
    if ($args{method} eq 'best') {
        $item = TAEB->has_item("wand of fire")
             || TAEB->has_item("wand of lightning")
             || TAEB->has_item("athame")
             || TAEB->has_item("Magicbane")
             || TAEB->has_item("wand of digging")
             || TAEB->has_item("magic marker")
             || '-';
    }
    else {
        $item = TAEB->has_item("athame")
             || TAEB->has_item("Magicbane")
             || '-';
    }

    $self->do(engrave => engraver => $item, add_engraving => $args{add_engraving});
}

=head2 pickup Item -> Bool

This will be called any time a pick-up menu is invoked. If your behavior knows
how to use items, this is how it can let TAEB know it should pick them up.

=cut

sub pickup { 0 }

=head2 drop Item -> Maybe Bool

This will be called any time a drop menu is invoked. If your behavior knows how
to use items, and when it no longer needs them, this is how it can let TAEB
know it should drop them.

If the return value is undefined, then this behavior doesn't care about the
particular item. If the return value is false, then this item should C<not> be
dropped, even if other behaviors say it should be.

=cut

sub drop { undef }

=head2 if_path Path, String|CODE[, Int] -> Int

If the first argument is undef or a path of length 0, then return 0 to indicate
"I don't want to be run."

If the first argument is defined and is a path of length greater than zero,
then use it as the current path. The behavior gets a "currently" of the second
argument (which may be a coderef -- this is useful it depends on $path being
valid), and return the third argument as the priority (or the default of
fallback). This replaces this code:

    if ($path) {
        $self->currently($currently);
        $self->do(move => path => $path);
        $self->urgency($ok);
    }
    return 0;

with

    $self->if_path($path => $currently, $ok);

=cut

sub _path_ok_for_travel {
    my $self = shift;
    my ($path) = @_;

    return if $self->travel_is_blacked_out;

    my $subpath = $path->intralevel_subpath;
    return unless $subpath;
    $subpath = $subpath->known_subpath;
    return unless $subpath;

    return if $subpath->length <= 5;

    return if $subpath->any_tile(sub {
        $_[1]->has_monster || $_[1]->type eq 'trap'
    });

    return $subpath;
}

sub if_path {
    my $self          = shift;
    my $original_path = shift;
    my $currently     = shift;

    unshift @_, 'urgency' if @_ % 2 == 1;
    my %opts = @_;

    $opts{urgency} = 'fallback' unless defined $opts{urgency};
    $opts{travel}  = 1          unless defined $opts{travel};

    return if !defined($original_path);

    my $length = $original_path->length;

    return if $length == 0;

    my $travel_path = $self->_path_ok_for_travel($original_path);
    if ($opts{travel} && $travel_path) {
        $self->do(travel => path => $travel_path);
    }
    else {
        $self->do(move => path => $original_path);
    }

    if (defined $currently) {
        if (ref($currently) eq 'CODE') {
            $self->currently($currently->());
        }
        else {
            $self->currently($currently);
        }
    }

    $self->urgency($opts{urgency});
}

=head2 done

Called when the action the behavior requested has been performed.

=cut

sub done {}

__PACKAGE__->meta->make_immutable;

1;

