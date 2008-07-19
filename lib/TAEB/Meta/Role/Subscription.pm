#!/usr/bin/env perl
package TAEB::Meta::Role::Subscription;
use Moose::Role;

requires '_app_init';
before _app_init => sub { TAEB->publisher->subscribe(shift) };

no Moose::Role;

1;

