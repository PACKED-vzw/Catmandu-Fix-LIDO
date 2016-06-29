package Catmandu::Fix::Bind::lido_bind;

use strict;

use Moo;

use Catmandu::Fix::move_field as => 'c_move_field';
use Catmandu::Fix::Has;

with 'Catmandu::Fix::Bind';

has dest	=>	(fix_arg => 1);
has root	=>	(fix_opt => 1, default => sub { 'lido_bind' });

sub unit {
	my ($self, $data) = @_;
	my $wrapped_data = $data;
	if (!$wrapped_data->{$self->root}) {
		$wrapped_data->{$self->root} = {};
	}
	return $wrapped_data;
}

sub bind {
	# Do all fixes, then move them to our event-hash
	my ($self, $data, $fixes, $name) = @_;
	my $path = [split(/\./, $self->dest)];
	# $fixes = all fixes that are in the do this(); end; block.
	# $append.event
	$fixes->($data);
	c_move_field($data, $self->root, join('.', @$path));
}

1;

__END__

=pod

=head1 NAME
Catmandu::Fix::lido_bind - Generic LIDO bind

=head1 SYNOPSIS
do lido_event_bind(
				dest: descriptiveMetadata.eventWrap.eventSet.$append.event,
				root: lido_bind
				)
	_fixes_
end

=head1 Description
Create a temporary root 'root' to apply fixes against and move it afterwards to 'dest'. 'root' is optional and defaults to 'lido_bind'.

