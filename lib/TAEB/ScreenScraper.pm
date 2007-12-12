#!/usr/bin/env perl
package TAEB::ScreenScraper;
use Moose;

has messages => (
    is => 'rw',
    isa => 'Str',
);

sub scrape {
    my $self = shift;
    my $out = '';

    # first, clear old data
    $self->clear;

    # handle --More--
    $out .= $self->handle_more;

    # handle menus
    $out .= $self->handle_menus;

    # handle other text
    $out .= $self->handle_fallback;

    # get rid of all the redundant spaces
    local $_ = $self->messages;
    s/\s+/ /g;
    $self->messages($_);

    return $out;
}

sub clear {
    my $self = shift;

    $self->messages('');
}

sub handle_more {
    my $self = shift;
    my $out = '';

    # while there's a --More-- on the screen..
    while ($main::taeb->vt->contains("--More--")) {
        # add the text to the buffer
        $self->messages($self->messages . $main::taeb->topline);

        # try to get rid of the --More--
        $main::taeb->interface->write(' ');
        $out .= $main::taeb->process_input();
    }

    return $out;
}

sub handle_menus {
    my $self = shift;
    my $out = '';

    # while there's a menu on the screen..
    while ($main::taeb->vt->matches(qr/\((?:end|\d+ of \d+)\)/)) {
        # try to get rid of it
        $main::taeb->interface->write(' ');
        $out .= $main::taeb->process_input();
    }

    return $out;
}

sub handle_fallback {
    my $self = shift;
    $self->messages($self->messages . $main::taeb->topline);
    return '';
}

1;

