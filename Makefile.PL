# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'TAEB';
all_from       'lib/TAEB.pm';

# for the telnet interface
requires       'IO::Socket::Telnet' => 0.02;

# for the local interface
requires       'IO::Pty::Easy';

# the object system
requires       'Moose';
requires       'MooseX::Singleton' => 0.03;

# getop for bin/taeb
requires       'Getopt::Whatever';

# parse escape codes into an addressable screen
requires       'Term::VT102::ZeroBased' => 1.01;

# human interaction
requires       'Term::ReadKey';

# logging
requires       'Log::Dispatch';

# config
requires       'YAML';
requires       'Hash::Merge';

# TAEB::Util
requires       'Sub::Exporter';
requires       'List::MoreUtils';

# pathfinding
requires       'Heap::Simple';

features(
    'ttyrec output' => [
        -default => 1,
        requires('Tie::Handle::TtyRec' => '0.02'),
    ],
    'REPL on exception' => [
        -default => 1,
        requires('Carp::REPL'),
    ],
);

build_requires 'Test::More';

install_script 'bin/taeb';

auto_install;
WriteAll;

