#!/usr/bin/env perl
package TAEB::AI::Behavior::Vault;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

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
        }, why => "VaultGuard");

        return $self->if_path($path, sub { "Following the vault guard" });
    }
}

sub drop {
    my $self = shift;
    my $item = shift;

    return unless TAEB->current_tile->in_vault
               && $item->match(appearance => 'gold piece');

    TAEB->debug("Dropping my gold because I'm in a vault");
    return 1;
}

sub urgencies {
    return {
        unimportant => "dropping gold",
        fallback    => "following the vault guard",
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

