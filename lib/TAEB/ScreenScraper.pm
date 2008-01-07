#!/usr/bin/env perl
package TAEB::ScreenScraper;
use Moose;
use NetHack::Menu;

my %msg_string = (
    "You are blinded by a blast of light!" =>
        ['msg_status_change', 'blindness', 1],
    "You can see again." =>
        ['msg_status_change', 'blindness', 0],
);

my @msg_regex = (
    [
        qr/^There is a (staircase (?:up|down)) here\.$/,
            ['msg_dungeon_feature', sub { $1 }],
    ],
);

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

    # iterate over the messages, invoke TAEB->send_message for each one we
    # know about
    MESSAGE: for (split /  /, $_) {
        if (exists $msg_string{$_}) {
            TAEB->enqueue_message(
                map { ref($_) eq 'CODE' ? $_->() : $_ }
                @{ $msg_string{$_} }
            );
            next MESSAGE;
        }
        for my $something (@msg_regex) {
            if ($_ =~ $something->[0]) {
                TAEB->enqueue_message(
                    map { ref($_) eq 'CODE' ? $_->() : $_ }
                    @{ $something->[1] }
                );
                next MESSAGE;
            }
        }
    }
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
    my $menu = NetHack::Menu->new(vt => TAEB->vt);

    return unless $menu->has_menu;

    my $selector;

    if (TAEB->topline =~ /Pick up what\?/) {
        $selector = TAEB->personality->can('pickup');
    }

    until ($menu->at_end) {
        TAEB->write($menu->next);
        TAEB->process_input();
    }

    # wrap selector method so it gets the right $self
    my $wrapper = $selector && sub {
        $selector->(TAEB->personality, @_);
    };

    $menu->select($wrapper) if $wrapper;
    TAEB->write($menu->commit);
    TAEB->process_input();
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

