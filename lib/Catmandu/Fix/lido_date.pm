package Catmandu::Fix::lido_date;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Value qw(mk_value);
use Catmandu::Fix::LIDO::Utility qw(declare_source);
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
                $r_code .= $fixer->emit_create_path(
                    $r_root,
                    ['earliestDate'],
                    sub {
                        my $d_root = shift;
                        my $d_code = '';

                        my $d_value = $fixer->generate_var();
                        $d_code .= "my ${d_value};";
                        $d_code .= declare_source($fixer, $self->earliest_date, $d_value);

                        $d_code .= "${d_root} = ${d_value};";
                        return $d_code;
                        }
                );
            }

            ##
            # latestDate
            if (defined($self->latest_date)) {
                $r_code .= $fixer->emit_create_path(
                    $r_root,
                    ['latestDate'],
                    sub {
                        my $d_root = shift;
                        my $d_code = '';

                        my $d_value = $fixer->generate_var();
                        $d_code .= "my ${d_value};";
                        $d_code .= declare_source($fixer, $self->latest_date, $d_value);

                        $d_code .= "${d_root} = ${d_value};";
                        return $d_code;
                        }
                );
            }

            return $r_code;
        }
    );
    
    return $perl;
}

1;