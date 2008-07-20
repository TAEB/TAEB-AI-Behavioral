#!/usr/bin/perl
package TAEB::Debug::Console;
use TAEB::OO;

sub msg_key {
    my $self = shift;
    my $key = shift;
    return unless $key eq '~';

    eval {
        local $SIG{__DIE__};

        $ENV{PERL_RL} ||= TAEB->config->readline;

        Curses::def_prog_mode();
        Curses::endwin();

        print "\n"
            . "\e[1;37m+"
            . "\e[1;30m" . ('-' x 50)
            . "\e[1;37m[ "
            . "\e[1;36mT\e[0;36mAEB \e[1;36mC\e[0;36monsole"
            . " \e[1;37m]"
            . "\e[1;30m" . ('-' x 12)
            . "\e[1;37m+"
            . "\e[m\n";

        no warnings 'redefine';
        require Devel::REPL::Script;
        local $TAEB::ToScreen;

        eval {
            local $SIG{INT} = sub { die "Interrupted." };
            Devel::REPL::Script->new->run;
        };
    };

    # we really do need to do this twice. my amateur opinion is that curses
    # isn't fully re-initialized when we call it the first time. oh well.
    TAEB->redraw(force_clear => 1) for 1..2;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
