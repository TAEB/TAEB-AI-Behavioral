#!/usr/bin/env perl
package TAEB::AI::Behavior::GotoTile;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

=head1 NAME

TAEB::AI::Behavior::GotoTile - generic go-to-a-tile-and-do-something behavior

=cut

sub prepare {
    my $self = shift;

    return URG_NONE unless $self->first_pass;

    # are we on the tile? if so, go for it
    my ($action, $currently) = $self->match_tile(TAEB->current_tile);
    if (ref($action) eq 'ARRAY' && @$action) {
        $self->currently($currently);
        $self->do(@$action);
        # XXX: priority should be variable
        return URG_UNIMPORTANT;
    }
    elsif (defined $action) {
        die blessed($self) . "->match_tile must return an array reference and a 'currently' string, or undef.";
    }

    # find our tile
    my $path = TAEB::World::Path->first_match(
        sub { ($self->match_tile(@_))[0] },
        why => ((blessed $self) =~ /.*::(.*)/),
    );

    $self->if_path($path => $self->currently_heading);
}

sub first_pass { 1 }

sub urgencies {
    my $self = shift;

    return {
        URG_UNIMPORTANT, $self->using_urgency,
        URG_FALLBACK,    $self->heading_urgency,
    };
}

# you may override these methods to provide more Englishy descriptions
sub using_urgency     { "using " . shift->tile_description }
sub heading_urgency   { "heading towards " . shift->tile_description }
sub currently_heading { "Heading towards " . shift->tile_description }

=head2 match_tile Tile -> ([Name, Args], Str)

This will try to match the given tile. If successful, it returns the arguments
to C<do> (the action name and its initial arguments) and the "currently"
string. Otherwise, return C<undef>.

=cut

sub match_tile {
    my $class = blessed($_[0]) || $_[0];
    confess "$class must override match_tile.";
}

=head2 tile_description

This returns a short string describing the tile that we're heading towards. For
example, the Descend behavior uses "the downstairs".

=cut

sub tile_description {
    my $class = blessed($_[0]) || $_[0];
    confess "$class must override tile_description.";
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

