#!/usr/bin/env perl
use strict;
use warnings;
use TAEB::Test tests => 13;

my $balsa = TAEB->new_item('a - a balsa wand');

ok($balsa->_match(undef, undef), "undef should match undef!");
ok(!$balsa->_match(undef, 'foo'), "seeking undef, found something");
ok(!$balsa->_match('foo', undef), "undef shouldn't match anything");

ok($balsa->match(identity => undef, class => 'wand'), "Is a wand");
ok(!$balsa->match(identity => 'wand of teleportation'), "Is not known as a wand of teleportation");
ok($balsa->match(not_identity => 'wand of teleportation'), "checking not_identity");

$balsa->identify_as('wand of teleportation');

ok($balsa->identity eq 'wand of teleportation', "checking raw identity string");

ok(!$balsa->match(identity => undef, class => 'wand'), "Is not unidentified");
ok($balsa->match(identity => 'wand of teleportation'), "Is definately a wand of teleportation");
ok($balsa->match(not_identity => 'wand of foo'), "Isn't a wand of foo");
ok(!$balsa->match(not_identity => 'wand of teleportation'), "Isn't not a wand of teleportation");

ok($balsa->match(not_identity => undef), "identity is not undef");
ok($balsa->match(identity => sub { shift eq 'wand of teleportation'}), "Code test");
