#!/usr/bin/env perl
use strict;
use warnings;
use TAEB::Test tests => 14;

my $balsa = TAEB->knowledge->appearances->{wand}{'balsa wand'};
ok($balsa, "we have an appearance object for balsa wands");

ok($balsa->engrave_useful, "wands usually start out being useful to engrave");

ok($balsa->has_possibility("wand of teleportation"));
$balsa->identify_as("wand of teleportation");
ok(!$balsa->engrave_useful, "no, balsa is teleportation, not useful to engrave");

my $maple = TAEB->knowledge->appearances->{wand}{'maple wand'};
ok($maple, "we have an appearance object for maple wands");
ok($maple->engrave_useful, "wands usually start out being useful to engrave");

$maple->rule_out_all_but("wand of wishing", "wand of death");
is($maple->possibilities, 2, "two possibilities left");
ok($maple->engrave_useful, "yes, wishing and death give different engrave results");

$maple->rule_out_all_but("wand of sleep", "wand of death");
is($maple->possibilities, 1, "all done");
ok(!$maple->engrave_useful, "nope, we've got only one engrave group now");

my $glass = TAEB->knowledge->appearances->{wand}{'glass wand'};
ok($glass, "we have an appearance object for glass wands");
ok($glass->engrave_useful, "wands usually start out being useful to engrave");

$glass->rule_out_all_but(map { +"wand of $_" => 1 } "teleportation", "cancellation", "make invisible", "fire");
ok($glass->engrave_useful, "glass is useful because it has two engrave groups left");

$glass->rule_out("wand of fire");
ok(!$glass->engrave_useful, "glass is no longer useful because it has one engrave group left");
