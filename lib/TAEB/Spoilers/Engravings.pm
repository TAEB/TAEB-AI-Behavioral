#!/usr/bin/env perl
package TAEB::Spoilers::Engravings;
use TAEB::OO;
use List::MoreUtils 'any';

our %rubouts = (
    0   => ' (?C',
    1   => ' ?|',
    6   => ' ?co',
    7   => ' /?',
    8   => ' 3?co',
    ":" => ' .?',
    ";" => ' ,?',
    A   => ' ?^',
    B   => ' -?FP[b|',
    b   => ' ?|',
    C   => ' (?',
    D   => ' )?[|',
    d   => ' ?c|',
    E   => ' -?FL[_|',
    e   => ' ?c',
    F   => ' -?|',
    G   => ' (?C',
    g   => ' ?c',
    H   => ' -?|',
    h   => ' ?nr',
    I   => ' ?|',
    j   => ' ?i',
    K   => ' <?|',
    k   => ' ?|',
    L   => ' ?_|',
    l   => ' ?|',
    M   => ' ?|',
    m   => ' ?nr',
    N   => ' ?\\|',
    n   => ' ?r',
    O   => ' (?C',
    o   => ' ?c',
    P   => ' -?F|',
    Q   => ' (?C',
    q   => ' ?c',
    R   => ' -?FP|',
    T   => ' ?|',
    U   => ' ?J',
    V   => ' /?\\',
    W   => ' /?V\\',
    w   => ' ?v',
    y   => ' ?v',
    Z   => ' /?'
);

sub is_degradation {
    my $self = shift;
    my $orig = shift;
    my $cur  = shift;

    return 0 if length($cur) > length($orig);

    # NetHack will eliminate trailing spaces, so we can just ignore any
    # characters that are after the end of the current string
    chop $orig until length($cur) == length($orig);

    my @orig = split '', $orig;
    my @cur  = split '', $cur;

    while (@orig && @cur) {
        my $o = shift @orig;
        my $c = shift @cur;

        next if $o eq $c;
        next if any { $_ eq $c } split '', ($rubouts{ $o } || ' ?');

        return 0;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

