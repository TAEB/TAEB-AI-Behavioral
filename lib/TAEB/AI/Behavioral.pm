package TAEB::AI::Behavioral;
use strict;
use warnings;

our $VERSION = '0.01';

sub new { die "Do not use TAEB::AI::Behavioral directly. Use a Personality subclass, such as TAEB::AI::Behavioral::Personality::Explorer." }

1;

__END__

=head1 NAME

TAEB::AI::Behavioral - behavioral AI for TAEB

=head1 DESCRIPTION

=head1 CODE

TAEB-AI-Behavioral is versioned using C<darcs>. You can get a checkout of the
code with:

    darcs get --partial http://sartak.org/code/TAEB-AI-Behavioral

=head1 AUTHORS

The primary authors of TAEB-AI-Behavioral are:

=over 4

=item Shawn M Moore C<sartak@gmail.com>

=item Jesse Luehrs C<doy@tozt.net>

=item Stefan O'Rear C<stefanor@cox.net>

=back

TAEB-AI-Behavioral has also had features, fixes, and improvements from:

=over 4

=item arcanehl

=item toft

=back

=head1 COPYRIGHT & LICENSE

Copyright 2007-2009 TAEB DevTeam.

This program is free software; you can redistribute it and/or modify it
under terms of the GNU public license version 2.

=cut
