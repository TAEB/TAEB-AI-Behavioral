#!/usr/bin/env perl
package TAEB::Action::Descend;
use Moose;
extends 'TAEB::Action';

use constant command => '>';

make_immutable;

1;

