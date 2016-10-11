package Catmandu::Fix::lido_term;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Term qw(mk_term);
use Data::Dumper qw(Dumper);

use strict;

with 'Catmandu::Fix::Base';

has path      => ( fix_arg => 1);
has term      => ( fix_arg => 1 );
has conceptid => ( fix_opt => 1 );
has lang      => ( fix_opt => 1, default => sub { 'en' } );
has pref      => ( fix_opt => 1, default => sub { 'preferred' } );
has source    => ( fix_opt => 1, default => sub { 'AAT' } );
has type      => ( fix_opt => 1, default => sub { 'global' } );

sub emit {
    my ( $self, $fixer ) = @_;

 #   print Dumper $fixer;

    my $perl = '';

    print($self->pref);
    
    $perl .= mk_term($fixer, $fixer->var, $self->path, $self->term, $self->conceptid,
    $self->lang, $self->pref, $self->source, $self->type);

    return $perl;
}

1;

__END__