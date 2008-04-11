#!/usr/bin/env perl
package TAEB::Meta::Types;
use Moose::Util::TypeConstraints;
use TAEB::Util 'tile_types';

=head1 NAME

TAEB::Meta::Types - TAEB-specific types

=cut

enum PlayState => qw(logging_in playing saving);

enum Role   => qw(Arc Bar Cav Hea Kni Mon Pri Ran Rog Sam Tou Val Wiz);
enum Race   => qw(Hum Elf Dwa Gno Orc);
enum Align  => qw(Law Neu Cha);
enum Gender => qw(Mal Fem Neu);

enum BUC    => qw(blessed uncursed cursed);
enum ItemClass => qw(gold weapon armor food scroll spellbook potion amulet ring wand tool gem other);

enum TileType => tile_types;

enum DoorState => qw(locked unlocked);

enum 'TAEB::Type::Branch' => qw(dungeons mines sokoban quest ludios gehennom vlad planes);

1;

