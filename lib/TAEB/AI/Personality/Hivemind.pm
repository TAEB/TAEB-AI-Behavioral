#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind;
BEGIN {
    use Template::Declare::Tags;
    delete ${TAEB::AI::Personality::Hivemind::}{meta}
}
use TAEB::OO;
use Template::Declare::Anon;
extends 'TAEB::AI::Personality';

sub next_action {
    $main::request->print(anon_template {
        html {
            body {
                form {
                    input {
                        attr {
                            id        => "cmd",
                            type      => "text",
                            size      => 1,
                            maxlength => 1,
                            name      => "c",
                        }
                    }
                }
                script {
                    outs_raw 'document.getElementById("cmd").focus()';
                }
                pre {
                    TAEB->vt->as_string("\n");
                }
            }
        }
    });

    $main::request->next;
    my $c = substr($main::request->param('c'), 0, 1);
    return TAEB::Action->new_action(custom => string => $c);
}

sub respond {
    $main::request->print(anon_template {
        html {
            body {
                pre {
                    TAEB->topline;
                }
                form {
                    input {
                        attr {
                            id        => "cmd",
                            type      => "text",
                            size      => 20,
                            name      => "c",
                        }
                    }
                }
                script {
                    outs_raw 'document.getElementById("cmd").focus()';
                }
                pre {
                    TAEB->vt->as_string("\n", 1);
                }
            }
        }
    });

    $main::request->next;
    return $main::request->param('c');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

