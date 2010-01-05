package TAEB::AI::Behavioral::Behavior::Vault;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    if (TAEB->gold > 0 && $self->drop(TAEB->new_item('1 gold piece'))) {
        $self->do('drop');
        $self->currently("Dropping my gold");
        $self->urgency('unimportant');
        return;
    }

    return if TAEB->any_adjacent(sub {
        my $monster = shift->monster;
        return defined $monster && $monster->is_vault_guard;
    });

    if (TAEB->following_vault_guard) {
        my $path = TAEB::World::Path->first_match(sub {
            my $monster = shift->monster;
            return defined $monster && $monster->is_vault_guard;
        });

        return $self->if_path($path, sub { "Following the vault guard" });
    }
}

use constant max_urgency => 'unimportant';

sub drop {
    my $self = shift;
    my $item = shift;

    return unless TAEB->current_tile->in_vault
               && $item->match(appearance => 'gold piece');

    TAEB->log->behavior("Dropping my gold because I'm in a vault");
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;

