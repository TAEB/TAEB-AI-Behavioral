use inc::Module::Install;

name           'TAEB-AI-Behavioral';
all_from       'lib/TAEB/AI/Behavioral.pm';

requires 'TAEB';

requires 'Scalar::Defer';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Time::HiRes';

build_requires 'Test::More';

WriteAll;

