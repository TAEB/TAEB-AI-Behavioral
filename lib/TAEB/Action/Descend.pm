#!/usr/bin/env perl
package TAEB::Action::Descend;
use TAEB::OO;
extends 'TAEB::Action::Ascend';

use constant command => '>';

__PACKAGE__->meta->make_immutable;
no Moose;

1;

