#!/usr/bin/env perl
package TAEB::Action::Gold;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => '$';

__PACKAGE__->meta->make_immutable;
no Moose;

1;

