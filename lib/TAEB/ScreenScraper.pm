#!/usr/bin/env perl
package TAEB::ScreenScraper;
use Moose;

has messages => (
    is => 'rw',
    isa => 'Str',
);

sub scrape {
    my $self = shift;
    my $taeb = shift;

    # first, clear old data
    $self->clear($taeb);

    # handle --More--
    $self->handle_more($taeb);

    # handle menus
    $self->handle_menus($taeb);

    # get rid of all the redundant spaces
    local $_ = $self->messages;
    s/\s+/ /g;
    $self->messages($_);
}

sub clear {
    my $self = shift;
    my $taeb = shift;

    $self->messages('');
}

sub handle_more {
    my $self = shift;
    my $taeb = shift;

    # while there's a --More-- on the screen..
    while ($taeb->vt->contains("--More--")) {
        # add the text to the buffer
        $self->messages($self->messages . $taeb->topline);

        # try to get rid of the --More--
        $taeb->interface->write(' ');
        $taeb->process_input();
    }
}

sub handle_menus {
    my $self = shift;
    my $taeb = shift;

    # while there's a menu on the screen..
    while ($taeb->vt->matches(qr/\((?:end|\d+ of \d+)\)/)) {
        # try to get rid of it
        $taeb->interface->write(' ');
        $taeb->process_input();
    }
}

1;

