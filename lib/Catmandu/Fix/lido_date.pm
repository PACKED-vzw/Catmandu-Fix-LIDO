package Catmandu::Fix::lido_date;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Value qw(mk_value);
use Data::Dumper qw(Dumper);

use strict;

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);
has earliest_date => (fix_opt => 1);
has latest_date => (fix_opt => 1);

sub emit {
    my ($self, $fixer) = @_;
    my $perl = '';
    my $new_path = $fixer->split_path($self->path);

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $new_path,
        sub {
            my $r_root = shift;
            my $r_code = '';

            ##
            # earliestDate
            # $fixer, $root, $path, $value, $lang, $pref, $label, $type, $is_string
            if (defined($self->earliest_date)) {
                $r_code .= mk_value($fixer, $r_root, 'earliestDate', $self->earliest_date);
            }

            ##
            # latestDate
            if (defined($self->latest_date)) {
                $r_code .= mk_value($fixer, $r_root, 'latestDate', $self->latest_date);
            }

            return $r_code;
        }
    );
    
    return $perl;
}

1;