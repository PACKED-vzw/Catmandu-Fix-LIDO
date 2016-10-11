package Catmandu::Fix::lido_baseid;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);
use Catmandu::Fix::LIDO::ID qw(mk_id);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

use Data::Dumper qw(Dumper);

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);
has id_value => (fix_arg => 1);
has type => (fix_opt => 1);
has source => (fix_opt => 1);
has label => (fix_opt => 1);

sub emit {
	my ($self, $fixer) = @_;
	my $perl = '';
	
	$perl .= mk_id($fixer, $fixer->var, $self->path, $self->id_value, $self->source, $self->label, $self->type);
	
	$perl;
}

1;

__END__

=pod

=head1 NAME

Catmandu::Fix::lido_recid - Create a Lido lidoRecID

=head1 SYNOPSIS

lido_recid(lidoRecID, type)