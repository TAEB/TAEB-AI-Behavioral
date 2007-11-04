#!/usr/bin/env perl
package TAEB::Interface;
use Moose;

sub read    { die "You must override the 'read' method in TAEB::Interface."  }
sub write   { die "You must override the 'write' method in TAEB::Interface." }

1;

