use inc::Module::Install;

name           'TAEB-AI-Behavioral';
all_from       'lib/TAEB/AI/Behavioral.pm';

requires 'TAEB';

requires 'Scalar::Defer';
requires 'Scalar::Util';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Time::HiRes';
requires 'Module::Pluggable';

WriteAll;

