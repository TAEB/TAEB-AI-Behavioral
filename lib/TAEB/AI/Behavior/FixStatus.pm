#!/usr/bin/env perl
package TAEB::AI::Behavior::FixStatus;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    if (my @statuses = map { s/^is_//; $_ } grep { TAEB->senses->$_ } qw/is_blind is_stunned is_confused is_hallucinating/) {
        if (my $unihorn = TAEB->find_item("unicorn horn")) {
            $self->currently("Rubbing a unicorn horn to fix @statuses");
            $self->do->apply(item => $unihorn);
            return 100;
        }
    }

    if (TAEB->senses->is_blind) {
        if (my $carrot = TAEB->find_item("carrot")) {
            $self->currently("Eating a carrot to fix blindness");
            $self->do->eat(food => $carrot);
            return 80;
        }
    }

    if (TAEB->senses->is_lycanthropic) {
        if (my $wolfsbane = TAEB->find_item("sprig of wolfsbane")) {
            $self->currently("Eating wolfsbane to fix lycanthropy");
            $self->do->eat(food => $wolfsbane);
            return 80;
        }
    }
}

sub urgencies {
    return {
       100 => "using a unicorn horn to fix status effects",
        80 => "eating food to fix status effects",
    },
}

1;

