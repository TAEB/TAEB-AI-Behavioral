#!/usr/bin/env perl
package TAEB::AI::Behavioral::Behavior::FixHunger;
use TAEB::OO;
use List::Util 'sum';
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    # if we're on an altar, demand it be of our alignment
    my $altar_ok = TAEB->current_tile->type ne 'altar'
                || TAEB->current_tile->align eq TAEB->align;

    if (TAEB->can_pray && TAEB->nutrition < 2 && $altar_ok) {
        $self->do("pray");
        $self->currently("Praying for food.");
        $self->urgency('critical');
        return;
    }

    if (TAEB->nutrition < 200 && TAEB::Action::Eat->any_food) {
        my ($item, $prio) = ('any', -1000);

        for my $meal (good_inv_food(0)) {
            my $p = $meal->weight / $meal->nutrition;

            $p -= 1000 if $meal->identity =~ qr/sprig|carrot|leaf|lump/;

            ($item,$prio) = ($meal,$p) if $prio < $p;
        }
        $self->do(eat => item => $item);
        $self->currently("Eating food.");
        $self->urgency('important');
        return;
    }
}

sub urgencies {
    return {
        critical  => "praying for food, while fainting",
        important => "eating food because nutrition is < 200",
    },
}

sub good_food {
    my $item = shift;
    my $great = shift;

    return 0 unless $item->match(weight => sub { $_ < 100 });
    return 0 unless TAEB::Spoilers::Item::Food->should_eat($item);
    return 0 if $great && $item->weight > (40 * $item->nutrition);

    return 1;
}

sub good_inv_food {
    my $great = shift;
    return grep { good_food($_, $great) } TAEB->inventory->items;
}

sub pickup {
    my $self = shift;
    my $item = shift;

    return 0 if !good_food($item);

    my $good = sum 0, map { $_->quantity * $_->nutrition } good_inv_food(1);
    my $food = sum 0, map { $_->quantity * $_->nutrition } good_inv_food(0);

    my $limit = 3000 - $food;

    if ($good >= 1500 && !good_food($item,1)) {
        $limit = 1500 - $good;
    }

    my $count = int($limit / $item->nutrition);

    return \$count;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

