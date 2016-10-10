package Catmandu::Fix::LIDO::Nameset

use Catmandu::Fix::LIDO::Utility qw(walk declare_source);

use strict;

use Exporter qw(import);

our @EXPORT_OK = qw(mk_nameset);

sub mk_nameset {
    my ($fixer, $path, $appellation_value, $appellation_value_lang, $appellation_value_type, $appellation_value_pref, $source_appellation, $source_appellation_lang) = @_;
    my $code = '';

    my $h = $fixer->generate_var();
    my $new_path = $fixer->split_path($path);
    $code .= "my ${h} = {};";

    ##
    # appellationValue
    if (defined($appellation_value)) {
        my $f_av = $fixer->generate_var();
        $code .= "my ${f_av};";
        $code .= declare_source($fixer, $appellation_value, $f_av);
    }

    ##
    # sourceAppellation
    if (defined($source_appellation)) {
        my $f_sa = $fixer->generate_var();
        $code .= "my ${f_sa};";
        $code .= declare_source($fixer, $source_appellation, $f_sa);
    }

    $code .= $fixer->emit_create_path(
        $fixer->var,
        $new_path,
        sub {
            my $root = shift;
            my $r_code = '';

            ##
            # appellationValue
            if (defined($appellation_value)) {
                $r_code .= $fixer->emit_create_path(
                    $root,
                    ['$append', 'appellationValue'],
                    sub {
                        my $av_root = shift;
                        my $av_code = '';
                        $av_code .= "${av_root} = {"
                        ."'_' => ${f_av},"
                        ."'lang' => '".$appellation_value_lang."',"
                        ."'pref' => '".$appellation_value_pref."',"
                        ."'type' => '".$appellation_value_type."'"
                        ."}";
                        return $av_code;
                    }
                );
            }

            ##
            # sourceAppellation
            if (defined ($source_appellation)) {
                $r_code .= $fixer->emit_create_path(
                    $root,
                    ['$append', 'sourceAppellation'],
                    sub {
                        my $sa_root = shift;
                        my $sa_code = '';
                        $sa_code .= "${sa_root} = {"
                        ."'_' => ${f_sa},"
                        ."'lang' => '".$source_appellation_lang."'"
                        ."}";
                        return $sa_code;
                    }
                );
            }

            return $r_code;
        }
    );

    return $code;
};

1;