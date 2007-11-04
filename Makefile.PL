# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'TAEB';
all_from       'lib//TAEB.pm';

requires       'IO::Socket::Telnet' => 0.02;
requires       'Moose';

build_requires 'Test::More';

auto_install;
WriteAll;

