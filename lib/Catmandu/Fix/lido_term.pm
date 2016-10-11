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
has lang      => ( fix_opt => 1 );
has pref      => ( fix_opt => 1 );
has source    => ( fix_opt => 1 );
has type      => ( fix_opt => 1 );

sub emit {
    my ( $self, $fixer ) = @_;

 #   print Dumper $fixer;

    my $perl = '';
    
    $perl .= mk_term($fixer, $fixer->var, $self->path, $self->term, $self->conceptid,
    $self->lang, $self->pref, $self->source, $self->type);

    return $perl;
}

1;

__END__