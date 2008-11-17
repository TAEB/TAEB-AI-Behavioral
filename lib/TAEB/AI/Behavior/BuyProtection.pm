#!/usr/bin/env perl
package TAEB::AI::Behavior::BuyProtection;
use TAEB::OO;
use TAEB::Util ':colors';

extends 'TAEB::AI::Behavior';

sub can_buy_protection {
    return TAEB->gold >= TAEB->level * 400;
}

sub prepare {
    my $self = shift;

    return URG_NONE unless $self->can_buy_protection;

    my $level = TAEB->nearest_level(sub {
        grep { $_->in_temple } shift->has_type('altar')
    });

    return URG_NONE unless $level;

    if (TAEB->current_tile->type eq 'altar' && TAEB->current_tile->in_temple) {
        my $found_priest;
        TAEB->each_adjacent(sub {
            my ($tile, $dir) = @_;
            if ($tile->has_monster && $tile->monster->is_priest) {
                my $amount = TAEB->level * 400;
                $self->do(chat => direction => $dir, 'amount' => $amount);
                $self->currently("Chatting to a priest");
                $found_priest = 1;
            }
        });
        return URG_UNIMPORTANT if $found_priest;
    }

    #find an altar to go to!
    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            $tile->type eq 'altar' && $tile->in_temple
        },
        on_level => $level,
        why => "BuyProtection",
    );

    $self->if_path($path => "Heading towards a temple altar");
}

sub urgencies {
    return {
        URG_UNIMPORTANT, "Donating for protection",
        URG_FALLBACK,    "Heading to temple altar",
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

