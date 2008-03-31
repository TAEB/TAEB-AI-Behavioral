#!/usr/bin/env perl
package TAEB::Knowledge::Item;
use TAEB::OO;

has appearance => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has type => (
    isa      => 'Str',
    required => 1,
);

has _identities => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef',
    default   => sub { {} },
    provides  => {
        delete => 'exclude_possibility',
        exists => 'has_possibility',
        keys   => 'possibilities',
    },
);

sub BUILD {
    my $self = shift;

    my $type = $self->type;
    my $class = ucfirst $type;
    my $spoiler = "TAEB::Spoilers::Item::$class";
    my $identity = $spoiler->constant_appearances->{$self->appearance}
        if $spoiler->can('constant_appearances');
    if (defined $identity) {
        $self->_identities->{$identity} = 1;
    }
    else {
        if ($spoiler->can('randomized_appearances') &&
            grep { $_ eq $self->appearance } $spoiler->randomized_appearances) {
            # XXX: we probably want a 'randomized_identities' attribute or
            # something like that, but we can't just do that directly with
            # what we have now because armor has multiple groups of
            # randomized_identities
            $self->_identities({ map { $_ => 1 } $spoiler->all_identities });
        }
        # XXX: we don't handle multi_identity_appearances here, since there's
        # no way to track this outside of game. handle them elsewhere through
        # #name-ing instead.
    }
}

around exclude_possibility => sub {
    my $orig        = shift;
    my $self        = shift;
    my $possibility = shift;

    my $appearance  = $self->appearance;
    my $type        = $self->type;

    my $class = ucfirst $type;

    # don't rule anything out for blind appearances.
    return if grep { $_ eq $appearance } ("TAEB::Spoilers::Item::$class"->blind_appearances);

    # ignore if we have only one possibility
    my @possibilities = $self->possibilities;
    if (@possibilities == 1) {
        if ($possibilities[0] eq $possibility) {
            TAEB->error("Tried to exclude the last possibility ($possibility) from ($type, $appearance)");
        }
        return;
    }

    $self->$orig($possibility);

    @possibilities = $self->possibilities;

    # uh oh, something bad happened
    if (@possibilities == 0) {
        TAEB->error("No possibilities left for ($type, $appearance)!");
        return;
    }

    # exclude my identity from the other appearances
    if (@possibilities == 1) {
        my $identity = shift @possibilities;
        TAEB->debug("($type, $appearance) is a '$identity'. Ruling it out of other appearances.");

        for my $other (values %{ TAEB->knowledge->appearances->{$type} }) {
            next if $other->appearance eq $appearance;
            my $spoiler = "TAEB::Spoilers::Item::" . ucfirst $type;
            next if grep { $other->appearance eq $_ }
                         $spoiler->blind_appearances;
            $other->rule_out($identity);
        }

        TAEB->knowledge->appearance_of->{$identity} = $appearance;
    }
};

sub rule_out {
    my $self = shift;
    $self->exclude_possibility($_) for @_;
}

sub rule_out_all_but {
    my $self = shift;
    my %include = map { $_ => 1 } @_;

    for ($self->possibilities) {
        $self->rule_out($_) unless $include{$_};
    }
}

sub identify_as {
    my $self = shift;
    $self->rule_out_all_but(shift);
}

sub is_identified {
    return shift->possibilities == 1;
}

# XXX: price-id code

__PACKAGE__->meta->make_immutable;
no Moose;

1;

