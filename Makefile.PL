# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'TAEB';
all_from       'lib//TAEB.pm';

requires       'IO::Socket::Telnet' => 0.02;
requires       'IO::Pty::Easy';
requires       'Moose';
requires       'Getopt::Whatever';

build_requires 'Test::More';

install_script 'bin/taeb';

auto_install;
WriteAll;

