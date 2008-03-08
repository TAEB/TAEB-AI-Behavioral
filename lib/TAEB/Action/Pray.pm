#!/usr/bin/env perl
package TAEB::Action::Pray;
use Moose;
extends 'TAEB::Action';

use constant command => "#pray\n";

make_immutable;

1;

