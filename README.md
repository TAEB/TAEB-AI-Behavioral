# Installing dependencies

This AI is packaged using [Dist::Zilla](http://dzil.org).

You should be able to install this module's dependencies by running
the following commands:

    dzil authordeps --missing | cpanm
    dzil listdeps --missing | cpanm

# Configuring TAEB for Behavioral

Adjust your configuration to use one of the Behavioral AIs in
`~/.taeb/config.yml`:

    ai: Behavioral::Personality::Explorer

# Running TAEB with Behavioral

Instruct TAEB to load `TAEB::AI::Behavioral`'s Perl code at
launch time like so:

    perl -Ilib -I/path/to/TAEB-AI-Behavioral/lib taeb

You can specify a relative directory to `-I`, so if you have `TAEB`
and `TAEB-AI-Behavioral` in the same parent directory, use this:

    perl -Ilib -I../TAEB-AI-Behavioral/lib taeb

