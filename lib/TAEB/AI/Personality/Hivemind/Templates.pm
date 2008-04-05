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
            select {
                attr {
                    name => "action",
                };

                for my $name (@TAEB::Action::actions) {
                    option {
                        attr {
                            value => $name,
                        };
                        $name
                    }
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
        form {
            for my $attr (@attrs) {
                label {
                    attr {
                        "for" => $attr->name
                    };
                    $attr->name
                }
                input {
                    attr {
                        id   => $attr->name,
                        type => "text",
                        name => $attr->name,
                    }
                }
            }
        }
    }
}

1;

