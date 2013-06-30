package TAEB::AI::Behavioral::Util;
use strict;
use warnings;

sub locktool {
    return TAEB->has_item('Master Key of Thievery')
        || TAEB->has_item('skeleton key')
        || TAEB->has_item('lock pick')
        || TAEB->has_item('credit card');

}

sub level_can_have_secret_doors {
    my $level = $_[0] || TAEB->current_level;

    return 1 unless $level->known_branch;

    my $branch = $level->branch;
    return 1 if $branch eq 'dungeons';
    return 0 if $branch eq 'sokoban';

    return 1 if $level->is_minetown;
    # XXX return 1 if $level->is_mines_end;
    return 0 if $branch eq 'mines';

    return 1;
}

1;
