#!/usr/bin/env perl
package TAEB::Util;
use strict;
use warnings;

sub tile_types {
    return qw(obscured rock wall floor door bars tree corridor stairs altar
              grave throne sink fountain water ice lava drawbridge air cloud
              underwater);
}

1;

