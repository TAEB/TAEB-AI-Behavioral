#!/usr/bin/env perl
package TAEB::Meta::Trait::GoodStatus;
use Moose::Role;

package Moose::Meta::Attribute::Custom::Trait::TAEB::GoodStatus;
sub register_implementation { 'TAEB::Meta::Trait::GoodStatus' }

1;

