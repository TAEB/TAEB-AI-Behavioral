# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'TAEB';
all_from       'lib/TAEB.pm';

# for the local interface
requires 'IO::Pty::Easy';

# the object system
requires 'Moose';
requires 'MooseX::Singleton' => 0.03;
requires 'MooseX::AttributeHelpers' => 0.09;
requires 'MooseX::AttributeHelper::Set::Object';
requires 'MooseX::ClassAttribute' => 0.07;
requires 'Module::Pluggable';

# getop for bin/taeb
requires 'Getopt::Whatever';

# parse escape codes into an addressable screen
requires 'Term::VT102::ZeroBased';

# print on an addressable screen
requires 'Curses';

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
requires 'Heap::Simple::XS'; # why doesn't Heap::Simple do this for us >_<
requires 'Memoize';

# miscellaneous
requires 'Time::HiRes';
requires 'Scalar::Defer';

# NetHack-specific things
requires 'NetHack::Menu' => '0.05';
requires 'NetHack::FOV';

features(
    'REPL on exception' => [
        -default => 1,
        recommends('Carp::REPL'),
    ],
    'TAEB for server NetHack' => [
        -default => 0,
        recommends('IO::Socket::Telnet'),
    ],
    'Various NetHack source bits' => [
        -default => 0,
        recommends('Inline::C'),
    ],
    'Hiveminder todo tracking' => [
        -default => 0,
        recommends('Net::Hiveminder'),
    ],
    'REPL on ~' => [
        -default => 1,
        recommends('Devel::REPL'),
        recommends('Term::ReadLine::Gnu'),
    ],
    'Source code and commit stats (bin/lc)' => [
        -default => 0,
        recommends("File::Next"),
    ],
    'Web-based interface for controlling TAEB' => [
        -default => 0,
        recommends('Continuity'),
        recommends('Template::Declare'),
        recommends('Template::Declare::Anon'),
    ],
    'IRC debug interface' => [
        -default => 0,
        recommends('Bot::BasicBot'),
        recommends('App::Nopaste'),
    ],
    'Log errors (and eventually deaths) to Twitter' => [
        -default => 0,
        recommends('Log::Dispatch::Twitter'),
    ],
);

build_requires 'Test::More';

install_script 'bin/taeb';

tests('t/*.t t/*/*.t');

auto_install;
WriteAll;

