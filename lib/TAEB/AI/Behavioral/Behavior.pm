package TAEB::AI::Behavioral::Behavior;
use TAEB::OO;

has currently => (
    isa => 'Str',
);

has action => (
    isa => 'TAEB::Action',
);

has urgency => (
    isa     => 'TAEB::Type::Urgency',
    clearer => 'reset_urgency',
);

=head2 prepare -> None

This should do any preparation required for the action it's going to take.
This includes things like pathfinding for Explore.

=cut

sub prepare { }

=head2 do Str, Args -> Action

This will create an Action of the given name, initialized with the given
arguments.

=cut

sub do {
    my $self = shift;
    my $name = shift;

    my $action = TAEB::Action->new_action($name => @_);
    $self->action($action);
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

    $self->do(engrave => item => $item, add_engraving => $args{add_engraving});
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

sub if_path {
    my $self      = shift;
    my $path      = shift;
    my $currently = shift;

    return if !defined($path) || length($path->path) == 0;

    $self->do(move => path => $path);

    if (defined $currently) {
        if (ref($currently) eq 'CODE') {
            $self->currently($currently->());
        }
        else {
            $self->currently($currently);
        }
    }

    $self->urgency(@_ ? shift : 'fallback');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

