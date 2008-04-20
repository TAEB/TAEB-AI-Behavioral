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
    my $level = TAEB->current_level;

    div {
        for my $y (1 .. 21) {
            for my $x (0 .. 79) {
                my $tile = $level->at($x, $y);

                outs_raw qq{<span class="tile-display" id="tile-$x-$y">};

                my $glyph = $tile->glyph;

                if ($glyph eq ' ') {
                    outs_raw "&nbsp;";
                }
                else {
                    outs $tile->glyph;
                }

                outs_raw '</span>';
            }
            br {};
        }
    }
    div {
        for my $y (1 .. 21) {
            for my $x (0 .. 79) {
                my $tile = $level->at($x, $y);
                tile($tile);
            }
        }
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
            head {
                title { "NetHack via HTTP" }
                script {
                    attr {
                        type => "text/javascript",
                        src => "http://sartak.org/jquery-1.2.3.js",
                    }
                }
                style {
                    attr {
                        type => "text/css",
                    }
                    outs "
                        .tile-info {
                            display: none;
                            position: absolute;
                            right: 10px;
                            top: 10px;
                            background: #CCCCCC;
                            border: 1px solid #000000;
                        }
                        .tile-display {
                            font-family: monospace;
                            padding: 0 0 0 0;
                            margin: 0 0 0 0;
                        }
                    "
                }
            }
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
                my $type = $attr->type_constraint->name;

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
                elsif ($type =~ /TAEB::World::Item/) {
                    $map{$name} = sub { TAEB->inventory->get(shift) };

                    select {
                        attr {
                            id   => $name,
                            name => $name,
                            @attrs == 1 ? onchange() : (),
                        };

                        for my $slot (TAEB->inventory->slots) {
                            my $item = TAEB->inventory->get($slot);
                            next unless $item->isa($type);

                            option {
                                attr { value => $slot };
                                $item->debug_line
                            }
                        }
                    }
                }
                elsif ($type =~ /Str|Int/) {
                    input {
                        attr {
                            id    => $name,
                            type  => "text",
                            name  => $name,
                            value => $attr->default,
                        }
                    }
                }
            }

            input {
                attr {
                    type => "submit",
                    value => $action_class->name . "!",
                }
            }
        }

        messages;
        level;
        botl;
    };

    return (\%map, scalar($print));
}

sub tile {
    my $tile = shift;
    div {
        attr {
            id => "tile-" . $tile->x . "-" . $tile->y . "-info",
            class => "tile-info",
        }

        pre {
            outs sprintf 'Coordinates: (%d, %d)', $tile->x, $tile->y;
            outs sprintf 'Glyph: %s', $tile->glyph;
            outs sprintf 'Floor: %s', $tile->floor_glyph;
        }
    }
}

1;

