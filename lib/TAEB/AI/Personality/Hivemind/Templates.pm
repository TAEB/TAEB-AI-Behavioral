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

require TAEB::Util;
my %color_class = map { s/^color_//; $_ }
                  map { lc }
                  reverse %TAEB::Util::colors;

sub level {
    my $level = TAEB->current_level;

    div {
        attr {
            id => "map",
        };

        my $taeb_x = TAEB->x;
        my $taeb_y = TAEB->y;

        for my $y (1 .. 21) {
            for my $x (0 .. 79) {
                my $tile = $level->at($x, $y);
                my $tag = $taeb_x == $x && $taeb_y == $y
                        ? 'span'
                        : 'a';

                my $color = $color_class{$tile->color};
                outs_raw qq{<$tag class="tile-display $color" id="tile-$x-$y"};
                outs_raw qq{ href="/?action=_Travel&x=$x&y=$y"} if $tag eq 'a';
                outs_raw qq{>};

                my $glyph = $tile->glyph;

                if ($glyph eq ' ') {
                    outs_raw "&nbsp;";
                }
                else {
                    outs $tile->glyph;
                }

                outs_raw "</$tag>";
            }
            br {};
        }
    }
    div {
        attr {
            id => "tile-info",
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
                        src  => "http://sartak.org/jquery-1.2.3.js",
                    }
                }
                script {
                    attr {
                        type => "text/javascript",
                    }
                    outs_raw << "                    JS";
                        jQuery(function () {
                            jQuery('.tile-display').hover(function () {
                                var tileid = this.id;
                                var id = tileid + '-info-wrap';
                                var tile = document.getElementById(id);

                                if (tile == null) {
                                    var all = 'tile-info';
                                    var info = document.getElementById(all);

                                    tile = document.createElement('div');
                                    tile.setAttribute('id', id);
                                    tile.setAttribute('class', 'tile-info');

                                    info.appendChild(tile);

                                    jQuery.get('/ajax-tile', {
                                        id: tileid
                                    }, function (data, textStatus) {
                                        tile.innerHTML = data;
                                    });
                                }

                                jQuery(tile).show();
                            },
                            function () {
                                var selector = '#' + this.id + '-info-wrap';
                                jQuery(selector).hide();
                            })
                        });
                    JS
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
                            color: #FFFFFF;
                            background: #000000;
                            text-decoration: none;
                        }
                        .tile-display:hover {
                            color: #FF0000;
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
                my $type = $attr->type_constraint;

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
                elsif ($type->name =~ /TAEB::World::Item/) {
                    $map{$name} = sub { TAEB->inventory->get(shift) };

                    my @items = grep { $type->check($_) }
                                map  { TAEB->inventory->get($_) }
                                TAEB->inventory->slots;

                    if (@items) {
                        select {
                            attr {
                                id   => $name,
                                name => $name,
                                @attrs == 1 ? onchange() : (),
                            };

                            for my $item (@items) {
                                option {
                                    attr { value => $item->slot };
                                    $item->debug_line
                                }
                            }
                        }
                    }
                    else {
                        span { "(No items to " . $action_class->name . ")" }
                    }
                }
                elsif ($type->name =~ /Str|Int/) {
                    input {
                        attr {
                            id    => $name,
                            type  => "text",
                            name  => $name,
                            value => $attr->default,
                        }
                    }
                }
                elsif ($type->name =~ /TAEB::Knowledge::Spell/) {
                    $map{$name} = sub { TAEB->spells->get(shift) };

                    my @spells = TAEB->spells->spells;
                    if (@spells) {
                        select {
                            attr {
                                id   => $name,
                                name => $name,
                                @attrs == 1 ? onchange() : (),
                            };

                            for my $spell (@spells) {
                                option {
                                    attr { value => $spell->slot };
                                    $spell->debug_line
                                }
                            }
                        }
                    }
                    else {
                        span { "(No spells to cast)" }
                    }

                }
            }

            input {
                attr {
                    type => "submit",
                    value => $action_class->name . "!",
                }
            }

            span {
                a { attr { href => "/?_return_to_command=1" } "(back)" }
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
        pre {
            my @attr = sort
                       map { $_->name }
                       $tile->meta->compute_all_applicable_attributes;

            for (@attr) {
                outs sprintf "%s: %s\n", $_, $tile->$_;
            }
        }
    }
}

1;

