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

sub botl {
    pre {
        TAEB->vt->as_string("\n", 22, 23)
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
        botl;
    }
}

sub respond {
    wrapper {
        messages;

        form {
            input {
                attr {
                    type => "text",
                    name => "c",
                }
            }
        }

        level;
        botl;
    }
}

sub action_arguments {
    my $self  = shift;
    my @attrs = @_;
    my $action_class = $attrs[0]->associated_class;

    wrapper {
        h2 { $action_class };
        for my $attr (@attrs) {
            h3 { $attr->name }
        }
    }
}

1;

