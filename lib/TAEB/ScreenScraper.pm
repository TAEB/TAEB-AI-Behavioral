#!/usr/bin/env perl
package TAEB::ScreenScraper;
use Moose;

has messages => (
    is => 'rw',
    isa => 'Str',
);

sub scrape {
    my $self = shift;

    # first, clear old data
    $self->clear;

    # handle --More--
    $self->handle_more;

    # this must come after --More-- handling
    die "Game over, man!\n"
        if $main::taeb->vt->row_plaintext(23) =~ /^--More--\s+$/;

    # handle menus
    $self->handle_menus;

    # handle other text
    $self->handle_fallback;

    # get rid of all the redundant spaces
    local $_ = $self->messages;
    s/\s+/ /g;
    $self->messages($_);
}

sub clear {
    my $self = shift;

    $self->messages('');
}

sub handle_more {
    my $self = shift;

    # while there's a --More-- on the screen..
    while ($main::taeb->vt->contains("--More--")) {
        # add the text to the buffer
        $self->messages($self->messages . $main::taeb->topline);

        # try to get rid of the --More--
        $main::taeb->write(' ');
        $main::taeb->process_input();
    }
}

sub handle_menus {
    my $self = shift;

    # while there's a menu on the screen..
    while ($main::taeb->vt->matches(qr/\((?:end|\d+ of \d+)\)/)) {
        # try to get rid of it
        $main::taeb->write(' ');
        $main::taeb->process_input();
    }
}

sub handle_fallback {
    my $self = shift;

    if ($main::taeb->topline =~ /^Really attack /) {
        # try to get rid of it
        $main::taeb->write('y');
        $main::taeb->process_input();
    }

    $self->messages($self->messages . $main::taeb->topline);
}

1;

