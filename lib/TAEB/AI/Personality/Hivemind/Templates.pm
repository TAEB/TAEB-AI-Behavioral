#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind::Templates;
use strict;
use warnings;
use Template::Declare::Tags;
use Template::Declare::Anon;

sub vt {
    pre {
        TAEB->vt->as_string("\n")
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

        vt;
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

        vt;
    }
}

1;

