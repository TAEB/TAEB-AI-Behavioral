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

degrade_progression(
    "Elbereth" =>
    "Elbcret?" =>
    "E|b?re ?" =>
    "F| ???"   =>
    "F  ???"   =>
    "F    ?"   =>
    "F"        =>
    "-"        =>
    ""
);

degrade_progression(
    "Elbereth" =>
    "Elbe?eth" =>
    "El e?et?" =>
    "El e e??" =>
    "El c e?"  =>
    "El c e"   =>
    "E  c ?"   =>
    "E  c"     =>
    "E  ?"     =>
    "E"        =>
    ""
);

degrade_progression(
    "               x" =>
                   "x" =>
                   ""
);

