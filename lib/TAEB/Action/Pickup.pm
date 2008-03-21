#!/usr/bin/env perl
package TAEB::Action::Pickup;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => ',';

# the screenscraper currently handles this code. it should be moved here

__PACKAGE__->meta->make_immutable;
no Moose;

1;

