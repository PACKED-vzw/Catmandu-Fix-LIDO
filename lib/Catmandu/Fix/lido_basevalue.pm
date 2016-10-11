package Catmandu::Fix::lido_basevalue;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);
use Catmandu::Fix::LIDO::Value qw(mk_value);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

use Data::Dumper qw(Dumper);

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);
has value => (fix_arg => 1);
has pref => (fix_opt => 1);
has lang => (fix_opt => 1);
has label => (fix_opt => 1);
has type => (fix_opt => 1);

sub emit {
    my ($self, $fixer) = @_;

    my $perl = '';

#$fixer, $root, $path, $value, $lang, $pref, $label, $type
    $perl .= mk_value($fixer, $fixer->var, $self->path, $self->value, $self->lang, $self->pref, $self->label, $self->type);

    return $perl;
}


1;