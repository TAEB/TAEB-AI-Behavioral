package TAEB::AI::Behavioral::Util;
use strict;
use warnings;

sub locktool {
    return TAEB->has_item('Master Key of Thievery')
        || TAEB->has_item('skeleton key')
        || TAEB->has_item('lock pick')
        || TAEB->has_item('credit card');

}

1;
