#!/usr/bin/env perl
package TAEB::Brain::NhBot;
use Moose;
extends 'TAEB::Brain';

=head1 NAME

TAEB::Brain::NhBot - Know thy roots

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head2 next_action TAEB -> STRING

Pray when Weak. #enhance when able.

If something is attacking TAEB, ; around the eight adjacent points to find it.
Then repeatedly attack it.

Otherwise, random walk.

=head3 State

What is the last direction we used ; in? Used as an index into the directions
array.

What monster last attacked us? That's the one we're looking for.

=cut

has last_direction => (
    is => 'rw',
    isa => 'Int',
);

has looking_for => (
    is => 'rw',
    isa => 'Str',
);

my @directions = (qw(h j k l y u b n), ' ');

sub next_action {
    my $self = shift;
    my $taeb = shift;

    # need food. must pray
    if ($taeb->vt->topline =~ /You (?:are beginning to )?feal weak\./) {
        $taeb->info("Feeling weak.");
        return "#pray\n";
    }
    # working out is useful for those floating eyes
    elsif ($taeb->vt->topline =~ /You feel more confident/) {
        $taeb->info("Got a 'feel more confident' message.");
        return "#enhance\na a \n";
    }
    # we just swiped at something, swing again in the same direction
    elsif ($taeb->vt->topline =~ /you (?:just )?(?:hit|miss) (?:(?:the |an? )([-.a-z ]+?)|it)[.!]/i) {
        $taeb->info("I either bumped into a monster or just attacked one.");
        return 'F' . $directions[$self->last_direction];
    }
    # under attack! start responding
    elsif ($taeb->vt->topline =~ /(?:(?:the |an? )([-.a-z ]+?)|it) (?:just )?(strikes|hits|misses|bites|grabs|stings|touches|points at you, then curses)(?:(?: at)? you(?:r displaced image)?)?[.!]/i) {
        $taeb->info("I'm being attacked by a $1! Looking for him..");
        $self->last_direction(-1);
        $self->looking_for($1);
        return $self->spin;
    }
    # looks like the output of ;
    elsif ($taeb->vt->topline =~ /^.\s*(.*)\(.*\)\s*$/) {
        $taeb->info("I spy with my little eye a $1.");
        my $looking_for = $self->looking_for;
        if ($taeb->vt->topline =~ /\Q$looking_for/) {
            # attack!
            $taeb->info("Found what I'm looking for!");
            return 'F' . $directions[$self->last_direction];
        }

        # ran out of directions and couldn't find it. gulp. just start moving
        # again
        if ($directions[$self->last_direction+1] eq ' ') {
            $taeb->info("I have no more directions to look at.");
            return $self->random;
        }

        # keep looking..
        $taeb->info("Still looking.");
        return $self->spin;
    }
    else {
        return $self->random;
    }
}

=head2 spin

This will look in the direction after last_direction. Make sure that
last_direction is set properly before calling this.

=cut

sub spin {
    my $self = shift;
    $self->last_direction($self->last_direction + 1);
    return ';' . $directions[$self->last_direction] . '.';
}

=head2 random

Walks in a random direction. Stores the direction it went in last_direction
so if you happen to hit something, you can strike again without spinning.

=cut

sub random {
    my $self = shift;

    my $dir = int rand @directions;
    $self->last_direction($dir);
    return $directions[$dir];
}

1;

