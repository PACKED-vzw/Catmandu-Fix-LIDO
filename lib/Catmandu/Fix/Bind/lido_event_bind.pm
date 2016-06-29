package Catmandu::Fix::Bind::lido_event_bind;

use strict;

use Moo;

use Catmandu::Fix::move_field as => 'c_move_field';
use Catmandu::Fix::add_field as => 'c_add_field';
use Catmandu::Fix::Has;

with 'Catmandu::Fix::Bind';

has lang         => ( fix_opt => 1, default => sub { 'en' } );

sub unit {
	my ($self, $data) = @_;
	my $wrapped_data = $data;
	if (!$wrapped_data->{'event'}) {
		$wrapped_data->{'event'} = {};
	}
	return $wrapped_data;
}

sub bind {
	# Do all fixes, then move them to our event-hash
	my ($self, $data, $fixes, $name) = @_;
	my $path = ['descriptiveMetadata', 'eventWrap', 'eventSet', '$append', 'event'];
	# $fixes = all fixes that are in the do this(); end; block.
	# $append.event
	$fixes->($data);
	c_move_field($data, 'event', join('.', @$path));
	if (!$data->{'descriptiveMetadata'}->{'lang'}) {
		c_add_field($data, 'descriptiveMetadata.lang', $self->lang);
	}
}

1;

__END__

=pod

=head1 NAME
Catmandu::Fix::lido_event_bind - Bind for LIDO Events

=head1 SYNOPSIS
do lido_event_bind()
	lido_event()
	add_field(event.eventName, 'bar')
end

=head1 Description
Creates a local 'event' context that can be used to create LIDO events. Instead of having to create the entire path (descriptiveMetadata.eventWrap.eventSet.$append.event) in your
fix, you can use the 'event' tag as root and create your fixes against that. Afterwards, this bind moves it to the correct position.

This has the added side-effect that you can group all tags related to a single event together, even if they can't be all expressed in a lido_event()-function. Otherwise,
using a normal fix (e.g. add_field) in combination with $append would result in the creation of a new event, making it almost impossible to add to an existing event.

