#!/usr/bin/env perl
package TAEB::AI::Personality::Hivemind;
use TAEB::OO;
use TAEB::AI::Personality::Hivemind::Templates;
extends 'TAEB::AI::Personality';

has action_calculator => (
    is      => 'rw',
    isa     => 'CodeRef',
    clearer => 'clear_action_calculator',
);

sub next_action {
    my $self = shift;

    my $calc = $self->action_calculator;
    if ($calc) {
        my $action = $calc->($self);
        return $action if $action;
    }

    {
        $main::request->print(TAEB::AI::Personality::Hivemind::Templates->next_action);
        $main::request->next;
        my $action = $self->fill_action($main::request->param('action'));
        redo if !$action;

        return $action;
    }
}

sub respond {
    my $messages = TAEB->all_messages("\n");

    $main::request->print(TAEB::AI::Personality::Hivemind::Templates->respond);
    $main::request->next;
    $main::request->param('c');
}

sub fill_action {
    my $self        = shift;
    my $name        = shift;

    if ($name eq '_Travel') {
        return $self->travel(@_);
    }

    my $pkg         = "TAEB::Action::$name";
    my $action_meta = $pkg->meta;
    my %args;

    my @required;
    for my $attr ($action_meta->compute_all_applicable_attributes) {

        # attribute isn't part of initialization
        next unless $attr->does('TAEB::Provided') && $attr->provided;

        # specified the argument early
        my $name = $attr->name;
        next if defined($args{$name} = $main::request->param($name));

        # need it, start a new request
        push @required, $attr;
    }

    return $pkg->new(%args) if !@required;

    my ($map, $out) = TAEB::AI::Personality::Hivemind::Templates->action_arguments(@required);
    $main::request->print($out);
    $main::request->next;

    return if $main::request->param('_return_to_command');

    for my $attr (@required) {
        my $name  = $attr->name;
        my $value = $main::request->param($name);
        $value = $map->{$name}->($value) if $map->{$name};
        $args{$name} = $value || $args{$name};
    }

    $pkg->new(%args);
}

sub travel {
    my $self = shift;
    my $x = $main::request->param('x');
    my $y = $main::request->param('y');

    my $target = TAEB->current_level->at($x, $y);
    my $path   = TAEB::World::Path->calculate_path($target);

    return if !$path->complete;

    my $action_number = 0;
    my @directions = split '', $path->path;

    TAEB->debug("Got a travel click. Travelling from "
            . "(" . TAEB->x . ", " . TAEB->y . ") "
            . "to ($x, $y) via @directions");

    $self->action_calculator(sub {
        my $self = shift;

        ++$action_number;

        my $direction = shift @directions;

        my $stop = 0;

        if (!$direction) {
            $stop = 1;
            TAEB->debug("Stopping travel because we ran out of directions.");
        }

        if (TAEB->current_level->has_enemies) {
            $stop = 1;
            TAEB->debug("Stopping travel because we have enemies on this level.");
        }

        # if we travel when there's a message on screen, don't stop
        if (TAEB->messages =~ /\S/ && $action_number > 1) {
            $stop = 1;
            TAEB->debug("Stopping travel because we got a message (" . TAEB->messages . ")");
        }

        if ($stop) {
            $self->clear_action_calculator;
            return;
        }

        return TAEB::Action::Move->new(direction => $direction);
    });

    $self->action_calculator->($self);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

