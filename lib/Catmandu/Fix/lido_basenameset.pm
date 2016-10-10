package Catmandu::Fix::lido_basenameset;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);
use Catmandu::Fix::LIDO::Nameset qw(mk_nameset);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

use Data::Dumper qw(Dumper);

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);
has value => (fix_arg => 1);
has value_pref => (fix_opt => 1, default => sub { 'preferred' });
has value_lang => (fix_opt => 1, default => sub { 'en' });
has source => (fix_opt => 1);
has source_lang => (fix_opt => 1, default => sub { 'en'}) ;

sub emit {
    my ($self, $fixer) = @_;

    my $perl = '';

#$fixer, $path, $appellation_value, $appellation_value_lang, 
#$appellation_value_type, $appellation_value_pref, $source_appellation, $source_appellation_lang
    $perl .= mk_nameset($fixer, $self->path, $self->value, $self->value_lang, undef, $self->value_pref,
    $self->source, $self->source_lang);

    return $perl;
}


1;