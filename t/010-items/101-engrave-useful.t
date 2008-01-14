#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 33;

use TAEB;

my $balsa = TAEB::Knowledge->appearances->{wand}{balsa};
ok($balsa, "we have an appearance object for balsa wands");

ok($balsa->engrave_useful, "wands usually start out being useful to engrave");

ok($balsa->has_possibility("wand of teleportation"));
$balsa->identify_as("wand of teleportation");
ok(!$balsa->engrave_useful, "no, balsa is teleportation, not useful to engrave");

my $maple = TAEB::Knowledge->appearances->{wand}{maple};
ok($maple, "we have an appearance object for maple wands");
ok($maple->engrave_useful, "wands usually start out being useful to engrave");

$maple->rule_out_all_but("wand of wishing", "wand of death");
is($maple->possibilities, 2, "two possibilities left");
ok($maple->engrave_useful, "yes, wishing and death give different engrave results");

$maple->rule_out_all_but("wand of sleep", "wand of death");
is($maple->possibilities, 1, "all done");
ok(!$maple->engrave_useful, "nope, we've got only one engrave group now");

