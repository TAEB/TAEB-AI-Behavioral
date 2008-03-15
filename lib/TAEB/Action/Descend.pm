#!/usr/bin/env perl
package TAEB::Action::Descend;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => '>';

make_immutable;
no Moose;

1;

