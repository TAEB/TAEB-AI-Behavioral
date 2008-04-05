#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind::Templates;
use strict;
use warnings;
use Template::Declare::Tags;
use Template::Declare::Anon;

sub onchange {
    onchange => "this.form.submit(); return 0;",
}

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

sub movement {
    my $include_misc = shift;

    table {
        row {
            cell { a { attr { href => "/?action=Move&direction=y" } "y" } }
            cell { a { attr { href => "/?action=Move&direction=k" } "k" } }
            cell { a { attr { href => "/?action=Move&direction=u" } "u" } }
        }
        row {
            cell { a { attr { href => "/?action=Move&direction=h" } "h" } };
            if ($include_misc) {
                cell { a { attr { href => "/?action=Move&direction=." } "." } }
            }
            else {
                cell { "." }
            }
            cell { a { attr { href => "/?action=Move&direction=l" } "l" } }
        }
        row {
            cell { a { attr { href => "/?action=Move&direction=b" } "b" } }
            cell { a { attr { href => "/?action=Move&direction=j" } "j" } }
            cell { a { attr { href => "/?action=Move&direction=n" } "n" } }
        };
        if ($include_misc) {
            cell { a { attr { href => "/?action=Move&direction=<" } "<" } }
            cell { a { attr { href => "/?action=Move&direction=>" } ">" } }
        }
    }
}

sub next_action {
    wrapper {
        table {
            row {
                cell {
                    form {
                        select {
                            attr {
                                name => "action",
                                onchange(),
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
                }
                cell {
                    movement;
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

                if ($attr->name eq 'direction') {
                    select {
                        attr {
                            id   => $name,
                            name => $name,
                            @attrs == 1 ? onchange() : (),
                        };

                        for my $dir (split '', 'hjklyubn.<>') {
                            option {
                                attr { value => $dir };
                                $dir
                            }
                        }
                    }
                }
                elsif ($attr->type_constraint->name =~ /TAEB::World::Item/) {
                    $map{$name} = sub { TAEB->inventory->get(shift) };

                    select {
                        attr {
                            id   => $name,
                            name => $name,
                            @attrs == 1 ? onchange() : (),
                        };

                        for my $slot (TAEB->inventory->slots) {
                            option {
                                attr { value => $slot };
                                TAEB->inventory->get($slot)->debug_line
                            }
                        }
                    }
                }
                elsif ($attr->type_constraint->name =~ qr/Str|Int/) {
                    input {
                        attr {
                            id   => $name,
                            type => "text",
                            name => $name,
                        }
                    }
                }
            }
        }

        messages;
        level;
        botl;
    };

    return (\%map, scalar($print));
}

1;

