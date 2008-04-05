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
    my $action_class = $attrs[0]->associated_class->name;
    my %map;

    my $print = wrapper {
        h2 { $action_class->name };
        form {
            for my $attr (@attrs) {
                my $name = $attr->name;
                label {
                    attr {
                        "for" => $name,
                    };
                    $name
                };

                if ($attr->type_constraint->name eq 'Str') {
                    input {
                        attr {
                            id   => $name,
                            type => "text",
                            name => $name,
                        }
                    }
                }
                elsif ($attr->type_constraint->name eq 'TAEB::World::Item') {
                    $map{$name} = sub { TAEB->inventory->get(shift) };

                    select {
                        attr {
                            id   => $name,
                            name => $name,
                        };

                        for my $slot (TAEB->inventory->slots) {
                            option {
                                attr { value => $slot };
                                TAEB->inventory->get($slot)
                            }
                        }
                    }
                }
            }
        }

        messages;
        level;
        botl;
    };

    return ($print, %map);
}

1;

