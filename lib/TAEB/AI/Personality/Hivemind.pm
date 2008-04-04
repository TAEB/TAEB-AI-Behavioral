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
                    select {
                        attr {
                            name => "action",
                        };

                        for my $name (@TAEB::Action::actions) {
                            option {
                                attr {
                                    value => $name,
                                }
                                $name
                            }
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
    my $action_name = $main::request->param('action');
    my $action_meta = "TAEB::Action::$action_name"->meta;

    my @required = grep { $_->provided }
                   $action_meta->compute_all_applicable_attributes;
    my %args;
    if (@required) {
        $main::request->print(anon_template {
            html {
                body {
                    form {
                        for my $attr (@required) {
                            my $name = $attr->name;

                            label {
                                attr { for => $name };
                                $name
                            }
                            input {
                                attr {
                                    id => $name,
                                    name => $name,
                                    type => "text",
                                };
                            }
                        }
                    }
                }
            }
        });

        $main::request->next;
        for my $attr (@required) {
            $args{$attr->name} = $main::request->param($attr->name);
        }
    }

    return "TAEB::Action::$action_name"->new(%args);
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

