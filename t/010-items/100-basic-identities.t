#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 33;

use TAEB;

ok(TAEB::Knowledge->appearances->{wand}{'balsa wand'}, "we have an appearance object for balsa wands");

my $balsa = TAEB::Knowledge->appearances->{wand}{'balsa wand'};
my %balsa_poss = map { $_ => 1} $balsa->all_identities;

is_deeply([sort $balsa->possibilities], [sort keys %balsa_poss], "we start with all possibilities.. possible");

$balsa->rule_out('wand of wishing');
delete $balsa_poss{"wand of wishing"};
is_deeply([sort $balsa->possibilities], [sort keys %balsa_poss], "we ruled out wands of wishing (how sad!)");

%balsa_poss = map { +"wand of $_" => 1 } qw/light death teleportation cancellation probing/;
$balsa->rule_out_all_but(keys %balsa_poss);
is_deeply([sort $balsa->possibilities], [sort keys %balsa_poss], "we just ruled out most wands, by looking at a chardump of the bones we just found (evil!)");

delete @balsa_poss{map {"wand of $_"} qw/light death probing/};
$balsa->rule_out_all_but(map { "wand of $_" } 'teleportation', 'cancellation', 'make invisible');
is_deeply([sort $balsa->possibilities], [sort keys %balsa_poss], "just engrave IDed and it's a vanisher");

$balsa->identify_as('wand of teleportation');
is_deeply([$balsa->possibilities], ['wand of teleportation'], "we used ?oID");

for (grep { $_ ne 'wand of teleportation' } $balsa->all_identities) {
    ok(!$balsa->has_possibility($_), "balsa cannot be $_, it's tele");
}
ok($balsa->has_possibility('wand of teleportation'), "yes! it's tele damnit, why don't you listen");

# ------------------------------------------------------------------------------

my $maple = TAEB::Knowledge->appearances->{wand}{'maple wand'};
my %maple_poss = map { $_ => 1} $maple->all_identities;
delete $maple_poss{"wand of teleportation"}; # that's balsa!

is_deeply([sort $maple->possibilities], [sort keys %maple_poss], "we start with all possibilities possible except for teleportation");

ok(!$maple->has_possibility('wand of teleportation'), "maple can not be teleportation");
ok($maple->has_possibility('wand of wishing'), "but maple can be wishing");

