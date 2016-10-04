package Catmandu::Fix::Bind::lido_bind;

use strict;

use Moo;

use Data::Dumper qw(Dumper);

use Catmandu::Fix;


with 'Catmandu::Fix::Bind';

extends 'Catmandu::Fix::Bind::with';

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

