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
has type => (fix_opt => 1, default => sub { 'global' });
has source => (fix_opt => 1);
has label => (fix_opt => 1, default => sub { 'dataPID' });

sub emit {
	my ($self, $fixer) = @_;
	my $recid_path = $fixer->split_path($self->id_value);
	my $recid_key = pop @$recid_path;
	
	my $new_path = $fixer->split_path($self->path);
	
	my $h = $fixer->generate_var();
	my $perl = '';
	$perl .= "my ${h};";
	
	$perl .= walk($fixer, $recid_path, $recid_key, $h);
	
	$perl .= mk_id($fixer, $new_path, $h, $self->source, $self->label, $self->type);
	
	$perl;
}

1;

__END__

=pod

=head1 NAME

Catmandu::Fix::lido_recid - Create a Lido lidoRecID

=head1 SYNOPSIS

lido_recid(lidoRecID, type)