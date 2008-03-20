#!/usr/bin/env perl
package TAEB::Action::Drop;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "Da\n";

# logic is elsewhere sadly

make_immutable;
no Moose;

1;

