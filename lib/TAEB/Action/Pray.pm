#!/usr/bin/env perl
package TAEB::Action::Pray;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => "#pray\n";

__PACKAGE__->meta->make_immutable;
no Moose;

1;

