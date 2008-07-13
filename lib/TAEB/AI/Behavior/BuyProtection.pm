#!/usr/bin/env perl
package TAEB::AI::Behavior::BuyProtection;
use TAEB::OO;
use TAEB::Util ':colors';

extends 'TAEB::AI::Behavior';

sub can_buy_protection {

    return unless TAEB->gold >= TAEB->level * 400;

    return 1;
}

sub prepare {
    my $self = shift;

    return 0 unless $self->can_buy_protection;

    my $level = TAEB->nearest_level(sub { grep { $_->in_temple } shift->has_type('altar') })
        or return 0;

    if (TAEB->current_tile->type eq 'altar' && TAEB->current_tile->in_temple) {
        my $found_monster;
        TAEB->each_adjacent(sub {
            my ($tile, $dir) = @_;
            if ($tile->has_monster && $tile->monster->is_priest) {
                my $amount = TAEB->level * 400;
                $self->do('Chat' => direction => $dir, 'amount' => $amount);
                $self->currently("Chatting to a priest");
                $found_monster = 1;
            }
        });
        return 100 if $found_monster;
    }

    #find an altar to go to!
    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            return $tile->type eq 'altar' && $tile->in_temple },
        on_level => $level,
        why => "BuyProtection",
    );

    $self->if_path($path => "Heading towards a temple altar");
}

sub urgencies {
    return {
        100 => "Donating for protection",
         50 => "Heading to temple altar",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

