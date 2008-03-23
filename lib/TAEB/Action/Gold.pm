#!/usr/bin/env perl
package TAEB::Action::Gold;
use TAEB::OO;
extends 'TAEB::Action';

use constant command => '$';

# if we have debt, then we'll get a message. otherwise, we have no debt, so
# we're good
sub done {
    if (!defined(TAEB->senses->debt)) {
        TAEB->senses->debt(0);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

