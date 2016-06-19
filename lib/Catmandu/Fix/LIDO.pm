package Catmandu::Fix::LIDO;

use strict;

# Stolen from Catmandu::Fix::Date
use parent 'Exporter';
our @EXPORT;
@EXPORT = qw(
    lido_title
    lido_repository
    lido_recid
    lido_worktype
    lido_description
    lido_event
    lido_recordwrap
);

our $VERSION = '0.218';

foreach my $fix (@EXPORT) {
    eval <<EVAL; ## no critic
        require Catmandu::Fix::$fix;
        Catmandu::Fix::$fix ->import( as => '$fix' );
EVAL
    die "Failed to use Catmandu::Fix::$fix\n" if $@;
}

1;

__END__

=pod

=head1 NAME

Catmandu::Fix::LIDO - Implement LIDO fixes

=head1 SYNOPSIS

A set of fixes for the Catmandu project to convert data to the LIDO XML format.

These fixes generate a data structure that can be exported to XML using the Catmandu LIDO exporter.

