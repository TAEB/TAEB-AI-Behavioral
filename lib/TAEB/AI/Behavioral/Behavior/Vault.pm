package TAEB::AI::Behavioral::Behavior::Vault;
use Moose;
use TAEB::OO;
extends 'TAEB::AI::Behavioral::Behavior';

sub prepare {
    my $self = shift;

    return unless TAEB->following_vault_guard || TAEB->current_tile->in_vault;

    if (TAEB->gold > 0 && $self->drop(TAEB->new_item('1 gold piece'))) {
        $self->do('drop', items => [ TAEB->inventory->find('gold piece') ]);
        $self->currently("Dropping my gold");
        $self->urgency('important');
        return;
    }

    my $vault_guard = TAEB->any_adjacent(sub {
        my $monster = shift->monster;
        return defined $monster && $monster->is_vault_guard;
    });
    if ($vault_guard) {
        $self->do('search', iterations => 1);
        $self->currently("Waiting for the vault guard to move");
        $self->urgency('important');
        return;
    }

    if (TAEB->following_vault_guard) {
        TAEB->log->vault("Trying to follow a vault guard");
        my $path = TAEB::World::Path->first_match(sub {
            my $monster = shift->monster;
            return defined $monster && $monster->is_vault_guard;
        }, include_endpoints => 1);

        return $self->if_path(
            $path,
            sub { "Following the vault guard" },
            'important'
        );
    }
}

use constant max_urgency => 'important';

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

