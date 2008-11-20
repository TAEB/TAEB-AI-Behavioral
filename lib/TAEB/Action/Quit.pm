#!/usr/bin/env perl
package TAEB::Action::Quit;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "#quit\n";

__PACKAGE__->meta->make_immutable;
no Moose;

1;

