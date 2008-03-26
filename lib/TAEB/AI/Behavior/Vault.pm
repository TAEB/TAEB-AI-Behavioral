#!/usr/bin/env perl
package TAEB::AI::Behavior::Vault;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    if (TAEB->senses->gold > 0 &&
        $self->drop(TAEB->new_item('1 gold piece'))) {
        $self->do('drop');
        $self->currently("Dropping my gold");
        return 100;
    }

    return 0 if TAEB->any_adjacent(sub {
        my $monster = shift->monster;
        return defined $monster && $monster->is_vault_guard;
    });

    if (TAEB->following_vault_guard) {
        my $path = TAEB::World::Path->first_match(sub {
            my $monster = shift->monster;
            return defined $monster && $monster->is_vault_guard;
        });

        return $self->if_path($path, sub { "Following the vault guard" }, 90);
    }

    return 0;
}

sub drop {
    my $self = shift;
    my $item = shift;

    return 0 unless TAEB->current_tile->in_vault &&
                    $item->appearance eq 'gold piece';
    TAEB->debug("Dropping my gold because I'm in a vault");
    return 1;
}

sub urgencies {
    return {
        100 => "dropping gold",
         90 => "following the vault guard",
    }
}

sub respond_vault_guard   { "TAEB\n" }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

