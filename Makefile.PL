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

# getop for bin/taeb
requires       'Getopt::Whatever';

# parse escape codes into an addressable screen
requires       'Term::VT102::ZeroBased';

# human brain
requires       'Term::ReadKey';

# logging
requires       'Log::Dispatch';

# config
requires       'YAML';
requires       'Hash::Merge';

build_requires 'Test::More';

install_script 'bin/taeb';

auto_install;
WriteAll;

