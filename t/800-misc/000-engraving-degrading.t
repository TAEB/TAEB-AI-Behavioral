#!/usr/bin/env perl
use strict;
use warnings;
use TAEB::Test tests => 52;

degrade_ok  "Elbereth" => "Elbereth";
degrade_ok  "Elbereth" => "Flbereth";
degrade_nok "Flbereth" => "Elbereth";
degrade_ok  "Elbereth" => "";
degrade_ok  "Elbereth" => "????????";
degrade_ok  "Elbereth" => "       ?";
degrade_nok "Elbereth" => "        ?";

my @progression = (
    "Elbereth" =>
    "Elgereth" =>
    "[lgereth" =>
    "[?gerc?r" =>
      "gcr??"  =>
      "ccr?"   =>
       "c??"   =>
        "??"   =>
         ""
);

for (my $i = 0; $i < @progression; ++$i) {
    for (my $j = $i; $j < @progression; ++$j) {
        degrade_ok($progression[$i] => $progression[$j]);
    }
}

