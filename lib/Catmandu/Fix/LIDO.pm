package Catmandu::Fix::LIDO;

use strict;

# Stolen from Catmandu::Fix::Date
use parent 'Exporter';
our @EXPORT;
@EXPORT = qw(
    lido_title
    lido_repository
);

foreach my $fix (@EXPORT) {
    eval <<EVAL; ## no critic
        require Catmandu::Fix::$fix;
        Catmandu::Fix::$fix ->import( as => '$fix' );
EVAL
    die "Failed to use Catmandu::Fix::$fix\n" if $@;
}


1;
