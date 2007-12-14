#!/usr/bin/env perl
use strict;
use warnings;

$| = 1;

while (1) {
    system("./bin/taeb");
    sleep 2;
    system("clear");
    for (1..58) {
        print ".";
    }
}

