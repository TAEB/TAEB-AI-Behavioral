#!/usr/bin/env perl
package TAEB::AI::Senses;
use Moose;
use Moose::Util::TypeConstraints;

enum Role   => qw(Arc Bar Cav Hea Kni Mon Pri Ran Rog Sam Tou Val Wiz);
enum Race   => qw(Hum Elf Dwa Gno Orc);
enum Align  => qw(Law Neu Cha);
enum Gender => qw(Mal Fem);

has role => (
    is  => 'rw',
    isa => 'Role',
);

has race => (
    is  => 'rw',
    isa => 'Race',
);

has align => (
    is  => 'rw',
    isa => 'Align',
);

has gender => (
    is  => 'rw',
    isa => 'Gender',
);

has hp => (
    is  => 'rw',
    isa => 'Int',
);

has maxhp => (
    is  => 'rw',
    isa => 'Int',
);

has nutrition => (
    is      => 'rw',
    isa     => 'Int',
    default => 700,
);

has in_wereform => (
    is  => 'rw',
    isa => 'Bool',
);

has can_kick => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

has is_blind => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has level => (
    is      => 'rw',
    isa     => 'Int',
    default => 1,
);

sub update {
    my $self = shift;

    # find role, race, gender, align
    local $_ = TAEB->messages;
    if (!$self->role && /welcome(?: back)? to NetHack/) {
        if (/You are a/) {
            $self->role(ucfirst lc $1) if /\b(Arc|Bar|Cav|Hea|Kni|Mon|Pri|Ran|Rog|Sam|Tou|Val|Wiz)/i;
            $self->race(ucfirst lc $1) if /\b(Hum|Elf|Dwa|Gno|Orc)/i;
            $self->align(ucfirst lc $1) if /\b(Law|Neu|Cha)/i;

            $self->gender(ucfirst lc $1) if /\b(Mal|Fem)/i;
            $self->gender('Mal') if /\b(priest\b|caveman)/i;
            $self->gender('Fem') if /\b(priestess|cavewoman|valkyrie)/i;
        }
    }

    my $status = TAEB->vt->row_plaintext(22);
    my $botl   = TAEB->vt->row_plaintext(23);

    if ($botl =~ /HP:(\d+)\((\d+)\)/) {
        $self->hp($1);
        $self->maxhp($2);
    }
    else {
        TAEB->error("Unable to parse HP from '$botl'");
    }

    if ($botl =~ m{Xp:(\d+)/(\d+)}) {
        $self->level($1);
    }
    else {
        TAEB->error("Unable to parse Experience from '$botl'");
    }

    $self->in_wereform($status =~ /^TAEB the Were/ ? 1 : 0);

    if (/You can't move your leg/ || /You are caught in a bear trap/) {
        $self->can_kick(0);
    }
    # XXX: there's no message when you leave a bear trap. I'm not sure of the
    # best solution right now. a way to say "run this code when I move" maybe

    # we lose 1 nutrition per turn. good enough for now
    $self->nutrition($self->nutrition - 1);

    # we can definitely know some things about our nutrition
    if ($botl =~ /\bSat/) {
        $self->nutrition(1000) if $self->nutrition < 1000;
    }
    elsif ($botl =~ /\bHun/) {
        $self->nutrition(149)  if $self->nutrition > 149;
    }
    elsif ($botl =~ /\bWea/) {
        $self->nutrition(49)   if $self->nutrition > 49;
    }
    elsif ($botl =~ /\bFai/) {
        $self->nutrition(-1)   if $self->nutrition > -1;
    }
    else {
        $self->nutrition(999) if $self->nutrition > 999;
        $self->nutrition(150) if $self->nutrition < 150;
    }

    $self->is_blind($botl =~ /\bBli/);
}

1;

