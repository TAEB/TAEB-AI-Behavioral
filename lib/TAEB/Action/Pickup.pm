#!/usr/bin/env perl
package TAEB::Action::Pickup;
use Moose;
extends 'TAEB::Action';

use constant command => ',',

# the screenscraper currently handles this code. it should be moved here

make_immutable;

1;

