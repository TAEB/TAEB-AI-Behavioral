package TAEB::AI::Behavioral::Behavior::BuyProtection;
use Moose;
use TAEB::OO;
use TAEB::Util ':colors';

extends 'TAEB::AI::Behavioral::Behavior';

sub can_buy_protection {
    return TAEB->gold >= TAEB->level * 400;
}

sub prepare {
    my $self = shift;

    return unless $self->can_buy_protection;

    my $level = TAEB->nearest_level(sub {
        grep { $_->in_temple } shift->has_type('altar')
    });

    return unless $level;

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
        return $self->urgency('unimportant') if $found_priest;
    }

    #find an altar to go to!
    my $path = TAEB::World::Path->first_match(
        sub {
            my $tile = shift;
            $tile->type eq 'altar' && $tile->in_temple
        },
        on_level => $level,
    );

    $self->if_path($path => "Heading towards a temple altar");
}

use constant max_urgency => 'unimportant';

__PACKAGE__->meta->make_immutable;

1;

