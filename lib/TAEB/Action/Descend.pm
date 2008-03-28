#!/usr/bin/env perl
package TAEB::Action::Descend;
use TAEB::OO;
extends 'TAEB::Action::Ascend';

use constant command => '>';
use constant complement_type => 'stairsup' => '<';

__PACKAGE__->meta->make_immutable;
no Moose;

1;

