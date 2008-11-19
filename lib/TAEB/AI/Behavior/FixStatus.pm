#!/usr/bin/env perl
package TAEB::AI::Behavior::FixStatus;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub apply  { { action  => 'apply',  item  => $_[0],
               urgency => $_[1],    check => sub { defined shift->{item} } } }
sub cast   { { action  => 'cast',   spell => $_[0], direction => '.',
               urgency => $_[1],    check => sub { defined shift->{spell} } } }
sub eat    { { action  => 'eat',    item  => $_[0],
               urgency => $_[1],    check => sub { defined shift->{item} &&
                                                   TAEB->nutrition < 1000 } } }
# XXX: handle invocation timeout too
sub invoke { { action  => 'invoke', item  => $_[0],
               urgency => $_[1],    check => sub { defined shift->{item} } } }
sub pray   { { action  => 'pray',
               urgency => $_[0],    check => sub { TAEB->senses->can_pray } } }
sub quaff  { { action  => 'quaff',  from  => 'potion of ' . $_[0],
               urgency => $_[1],    check => sub { defined shift->{from} } } }
sub scroll { { action  => 'read',   item  => 'scroll of ' . $_[0],
               urgency => $_[1],    check => sub { defined shift->{item} } } }
sub rest   { { action  => 'search',
               urgency => $_[0],    check => sub { 1 } } }
sub zap    { { action  => 'zap',    item  => 'wand of ' . $_[0],
               direction => '.',
               urgency => $_[1],    check => sub { defined shift->{item} } } }

has needs_fixing => (
    is => 'ro',
    isa => 'ArrayRef',
    auto_deref => 1,
    default => sub {
        [
            {
                status => 'stoning',
                check  => sub { TAEB->senses->is_petrifying },
                fixes  => [
                    eat(   'lizard corpse',        'critical'),
                    # acidic corpses
                    # acidic tins
                    quaff( 'potion of acid',       'critical'),
                    cast(  'stone to flesh',       'critical'),
                    pray(                          'critical'),
                ],
            },
            {
                status => 'food poisoning',
                check  => sub { TAEB->is_food_poisoned },
                fixes  => [
                    apply( 'unicorn horn',         'critical'),
                    cast(  'cure sickness',        'critical'),
                    eat(   'eucalyptus leaf',      'critical'),
                    invoke('Staff of Aesculapius', 'critical'),
                    quaff( 'extra healing',        'critical'),
                    quaff( 'full healing',         'critical'),
                    pray(                          'critical'),
                ],
            },
            {
                status => 'strangulation',
                check  => sub { 0 },
                fixes  => [
                    pray(                          'critical'),
                ],
            },
            {
                status => 'sliming',
                check  => sub { 0 },
                fixes  => [
                    cast(  'cure sickness',        'critical'),
                    invoke('Staff of Aesculapius', 'critical'),
                    scroll('fire',                 'critical'),
                    zap(   'fire',                 'critical'),
                    cast(  'fireball',             'critical'),
                    pray(                          'critical'),
                ],
            },
            {
                status => 'illness',
                check  => sub { TAEB->is_ill },
                fixes  => [
                    apply( 'unicorn horn',         'critical'),
                    cast(  'cure sickness',        'critical'),
                    invoke('Staff of Aesculapius', 'critical'),
                    quaff( 'extra healing',        'critical'),
                    quaff( 'full healing',         'critical'),
                    pray(                          'critical'),
                ],
            },
            {
                status => 'blindness',
                check  => sub { TAEB->senses->is_blind },
                fixes  => [
                    apply( 'unicorn horn',         'important'),
                    cast(  'extra healing',        'important'),
                    cast(  'cure blindness',       'important'),
                    eat(   'carrot',               'important'),
                    invoke('Staff of Aesculapius', 'important'),
                    quaff( 'see invisible',        'important'),
                    quaff( 'healing',              'important'),
                    quaff( 'extra healing',        'important'),
                    quaff( 'full healing',         'important'),
                    rest(                          'unimportant'),
                ],
            },
            {
                status => 'stunning',
                check  => sub { TAEB->senses->is_stunned },
                fixes  => [
                    apply( 'unicorn horn',         'important'),
                    rest(                          'unimportant'),
                ],
            },
            {
                status => 'confusion',
                check  => sub { TAEB->senses->is_confused },
                fixes  => [
                    apply( 'unicorn horn',         'important'),
                    rest(                          'unimportant'),
                ],
            },
            {
                status => 'hallucination',
                check  => sub { TAEB->senses->is_hallucinating },
                fixes  => [
                    apply( 'unicorn horn',         'important'),
                    quaff( 'extra healing',        'important'),
                    quaff( 'full healing',         'important'),
                    # potion of sickness
                    rest(                          'unimportant'),
                ],
            },
            {
                status => 'lycanthropy',
                check  => sub { TAEB->senses->is_lycanthropic },
                fixes  => [
                    eat(   'sprig of wolfsbane',   'important'),
                    quaff( 'holy water',           'important'),
                    pray(                          'important'),
                ],
            },
            {
                status => 'stat loss',
                check  => sub { 0 },
                fixes  => [
                    apply( 'unicorn horn',         'unimportant'),
                    cast(  'restore ability',      'unimportant'),
                    quaff( 'restore ability',      'unimportant'),
                    eat(   'lump of royal jelly',  'unimportant'),
                ],
            },
            {
                status => 'wounded legs',
                check  => sub { 0 },
                fixes  => [
                    eat(   'lump of royal jelly',  'unimportant'),
                    quaff( 'speed',                'unimportant'),
                    rest(                          'unimportant'),
                ],
            },
        ]
    },
);

sub prepare {
    my $self = shift;

    for my $status ($self->needs_fixing) {
        next unless $status->{check}->();
        TAEB->debug("Trying to fix $status->{status}");

        for my $fix (@{$status->{fixes}}) {
            my %args;

            $args{item}  = TAEB->find_item($fix->{item})   if $fix->{item};
            $args{from}  = TAEB->find_item($fix->{from})   if $fix->{from};
            $args{spell} = TAEB->find_spell($fix->{spell}) if $fix->{spell};
            $args{direction} = $fix->{direction}           if $fix->{direction};
            next unless $fix->{check}->(\%args);

            $self->do($fix->{action}, %args);
            $self->currently("Fixing $status->{status}");
            $self->urgency($fix->{urgency});
            return;
        }
    }
}

sub pickup {
    my $self = shift;
    my $item = shift;

    for my $fix (map { @{ $_->{fixes} } } $self->needs_fixing) {
        return 1 if defined $fix->{item} &&
                    defined $item->identity &&
                    $item->identity eq $fix->{item};
    }

    return;
}

sub urgencies {
    return {
        critical    => "fixing a life threatening status",
        important   => "fixing a problematic status",
        unimportant => "fixing an annoying status",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

