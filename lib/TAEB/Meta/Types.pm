#!/usr/bin/env perl
package TAEB::Meta::Types;
use Moose::Util::TypeConstraints;
use TAEB::Util 'tile_types';

=head1 NAME

TAEB::Meta::Types - TAEB-specific types

=cut

enum PlayState => qw(logging_in prepare_inventory prepare_crga playing saving);

enum Role   => qw(Arc Bar Cav Hea Kni Mon Pri Ran Rog Sam Tou Val Wiz);
enum Race   => qw(Hum Elf Dwa Gno Orc);
enum Align  => qw(Law Neu Cha);
enum Gender => qw(Mal Fem);

enum BUC    => qw(blessed uncursed cursed unknown);
enum ItemClass => qw(gold weapon armor food scroll spellbook potion amulet ring wand tool gem unknown);

enum TileType => tile_types;

1;

