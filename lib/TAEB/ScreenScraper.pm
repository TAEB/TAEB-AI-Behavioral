#!/usr/bin/env perl
package TAEB::ScreenScraper;
use Moose;

has messages => (
    is => 'rw',
    isa => 'Str',
);

sub scrape {
    my $self = shift;

    # very big special case
    if (TAEB->vt->row_plaintext(23) =~ /^--More--\s+$/) {
        TAEB->write('        ');
        die "Game over, man!\n";
    }

    # handle --More--
    $self->handle_more;

    # handle menus
    $self->handle_menus;

    # handle other text
    $self->handle_fallback;

    # get rid of all the redundant spaces
    local $_ = $self->messages;
    s/\s+ /  /g;
    $self->messages($_);
}

sub clear {
    my $self = shift;

    $self->messages('');
}

sub handle_more {
    my $self = shift;

    # while there's a --More-- on the screen..
    while (TAEB->vt->contains("--More--")) {
        # add the text to the buffer
        $self->messages($self->messages . TAEB->topline);

        # try to get rid of the --More--
        TAEB->write(' ');
        TAEB->process_input();
    }
}

sub handle_menus {
    my $self = shift;

    # while there's a menu on the screen..
    while (TAEB->vt->matches(qr/\((?:end|\d+ of \d+)\)/)) {
        # try to get rid of it
        TAEB->write(' ');
        TAEB->process_input();
    }
}

sub handle_fallback {
    my $self = shift;

    if (TAEB->topline =~ /^Really attack /) {
        # try to get rid of it
        TAEB->write('y');
        TAEB->process_input();
    }

    if (TAEB->topline =~ /^Call / && TAEB->vt->y == 0) {
        TAEB->write("\n");
        TAEB->process_input();
    }

    if (TAEB->topline =~ /^Really save\? / && TAEB->vt->y == 0) {
        TAEB->write("y");
        die "Game over, man!";
        TAEB->process_input();
    }

    $self->messages($self->messages . TAEB->topline);
}

1;

