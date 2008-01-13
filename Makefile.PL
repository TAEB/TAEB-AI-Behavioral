# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'TAEB';
all_from       'lib/TAEB.pm';

# for the telnet interface
requires 'IO::Socket::Telnet' => 0.02;

# the object system
requires 'Moose';
requires 'MooseX::Singleton' => 0.03;
requires 'MooseX::AttributeHelpers';

# getop for bin/taeb
requires 'Getopt::Whatever';

# parse escape codes into an addressable screen
requires 'Term::VT102::ZeroBased' => 1.01;

# human interaction
requires 'Term::ReadKey';

# logging
requires 'Log::Dispatch';

# config
requires 'YAML';
requires 'Hash::Merge';

# TAEB::Util
requires 'Sub::Exporter';
requires 'List::MoreUtils';

# pathfinding
requires 'Heap::Simple';

# miscellaneous
requires 'Scalar::Defer' => '0.12';
requires 'String::Koremutake';

# NetHack-specific things
requires 'NetHack::Menu' => '0.02';

features(
    'ttyrec output' => [
        -default => 1,
        requires('Tie::Handle::TtyRec' => '0.02'),
    ],
    'REPL on exception' => [
        -default => 1,
        requires('Carp::REPL'),
    ],
    'TAEB for local NetHack' => [
        -default => 0,
        requires('IO::Pty::Easy'),
    ],
    'Various NetHack source bits' => [
        -default => 0,
        requires('Inline::C'),
    ],
);

build_requires 'Test::More';

install_script 'bin/taeb';

auto_install;
WriteAll;

