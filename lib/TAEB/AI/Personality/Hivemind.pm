#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind;
use TAEB::OO;
use TAEB::AI::Personality::Hivemind::Templates;
extends 'TAEB::AI::Personality';

sub next_action {
    $main::request->print(TAEB::AI::Personality::Hivemind::Templates->next_action);
    $main::request->next;
    shift->fill_action($main::request->param('action'));
}

sub respond {
    $main::request->print(TAEB::AI::Personality::Hivemind::Templates->respond);
    $main::request->next;
    $main::request->param('c');
}

sub fill_action {
    my $self        = shift;
    my $name        = shift;
    my $pkg         = "TAEB::Action::$name";
    my $action_meta = $pkg->meta;
    my @required    = grep { $_->provided }
                      $action_meta->compute_all_applicable_attributes;
    return $pkg->new if !@required;

    my ($map, $out) = TAEB::AI::Personality::Hivemind::Templates->action_arguments(@required);
    $main::request->print($out);
    $main::request->next;

    my %args;

    for my $attr (@required) {
        my $name  = $attr->name;
        my $value = $main::request->param($name);
        $value = $map->{$name}->($value) if $map->{$name};
        $args{$name} = $value;
    }

    $pkg->new(%args);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

