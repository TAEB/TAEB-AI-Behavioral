#!perl -T
use strict;
use warnings;
use Test::More tests => 1;
use TAEB;

my $mon = TAEB::World::Monster->new(TAEB::Spoilers::Monster->monster("Aleax"));
like($mon->id, qr/^\w+$/, "got an id");
