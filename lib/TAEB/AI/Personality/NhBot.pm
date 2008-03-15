#!/usr/bin/env perl
package TAEB::AI::Personality::NhBot;
use TAEB::OO;
extends 'TAEB::AI::Personality';

=head1 NAME

TAEB::AI::Personality::NhBot - Know thy roots

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
    isa => 'Int',
);

has looking_for => (
    isa => 'Str',
);

my @directions = (qw(h j k l y u b n), ' ');

sub next_action {
    my $self = shift;

    # need food. must pray
    if (TAEB->messages =~ /You regain consciousness/) {
        $self->currently("Praying for satiation.");
        return "#pray\n";
    }
    elsif (TAEB->messages =~ /You (?:are beginning to )?feal weak\.|Valkyrie needs food!/) {
        $self->currently("Praying for satiation.");
        return "#pray\n";
    }
    # working out is useful for those floating eyes
    elsif (TAEB->messages =~ /You feel more confident/) {
        $self->currently("Enhancing my skills.");
        return "#enhance\na a \n";
    }
    # we just swiped at something, swing again in the same direction
    elsif (TAEB->messages =~ /you (?:just )?(?:hit|miss) (?:(?:the |an? )([-.a-z ]+?)|it)[.!]/i) {
        $self->currently("Re-attacking a monster.");
        return 'F' . $directions[$self->last_direction];
    }
    # under attack! start responding
    elsif (TAEB->messages =~ /(?:(?:the |an? )([-.a-z ]+?)|it) (?:just )?(strikes|hits|misses|bites|grabs|stings|touches|points at you, then curses)(?:(?: at)? you(?:r displaced image)?)?[.!]/i) {
        $self->currently("Looking for my assailant.");
        $self->last_direction(-1);
        $self->looking_for($1);
        return $self->spin;
    }
    # looks like the output of ;
    elsif (TAEB->messages =~ /^(?:.\s*(.*)\s*\(.*\)\s*|\| a wall)$/) {
        my $looking_for = $self->looking_for;
        if (TAEB->messages =~ /\Q$looking_for/) {
            # attack!
            $self->currently("Attacking my assailant.");
            return 'F' . $directions[$self->last_direction];
        }

        # ran out of directions and couldn't find it. gulp. just start moving
        # again
        if ($directions[$self->last_direction+1] eq ' ') {
            $self->currently("Lost my assailant.");
            return $self->random;
        }

        # keep looking..
        $self->currently("Looking around for my assailant.");
        return $self->spin;
    }
    else {
        TAEB->debug("Nothing interesting about " . TAEB->messages)
            unless TAEB->messages =~ /^\s*$/;
        $self->currently("Randomly walking.");
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

Walks in a random direction. Clears the last direction walked so that it
doesn't interfere with the combat system.

=cut

sub random {
    my $self = shift;

    $self->last_direction(-1);

    return $directions[rand @directions];
}

make_immutable;
no Moose;

1;

