#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind::Templates;
use strict;
use warnings;
use Template::Declare::Tags;
use Template::Declare::Anon;

sub messages {
    pre {
        TAEB->all_messages("\n")
    }
}

sub level {
    pre {
        TAEB->vt->as_string("\n", 1, 21)
    }
}

sub wrapper(&) {
    my $code = shift;

    anon_template {
        html {
            body {
                $code->();
            }
        }
    }
}

sub next_action {
    wrapper {
        form {
            input {
                attr {
                    type      => "text",
                    name      => "c",
                    size      => 1,
                    maxlength => 1,
                }
            }
        }

        messages;
        level;
    }
}

sub respond {
    wrapper {
        form {
            input {
                attr {
                    type => "text",
                    name => "c",
                }
            }
        }

        messages;
        level;
    }
}

1;

