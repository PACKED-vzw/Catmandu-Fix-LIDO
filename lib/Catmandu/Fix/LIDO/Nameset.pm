package Catmandu::Fix::LIDO::Nameset;

use Catmandu::Fix::LIDO::Utility qw(walk declare_source);
use Catmandu::Fix::LIDO::Value qw(mk_value);

use strict;

use Exporter qw(import);

our @EXPORT_OK = qw(mk_nameset);

sub mk_nameset {
    my ($fixer, $root, $path, $appellation_value, $appellation_value_lang, $appellation_value_type, $appellation_value_pref, $source_appellation, $source_appellation_lang) = @_;
    my $code = '';

    my $new_path = $fixer->split_path($path);

    my $f_av = $fixer->generate_var();
    my $f_sa = $fixer->generate_var();
    my $a_root = $fixer->var;
    if (defined($root)) {
        $a_root = $root;
    }

    ##
    # appellationValue
    if (defined($appellation_value)) {
        $code .= "my ${f_av};";
        $code .= declare_source($fixer, $appellation_value, $f_av);
    }

    ##
    # sourceAppellation
    if (defined($source_appellation)) {
        $code .= "my ${f_sa};";
        $code .= declare_source($fixer, $source_appellation, $f_sa);
    }

    $code .= $fixer->emit_create_path(
        $a_root,
        $new_path,
        sub {
            my $r_root = shift;
            my $r_code = '';

            ##
            # appellationValue
            if (defined($appellation_value)) {
                $r_code .= mk_value($fixer, $r_root, 'appellationValue', $appellation_value,
                $appellation_value_lang, $appellation_value_pref, undef, $appellation_value_type);
            }

            ##
            # sourceAppellation
            if (defined ($source_appellation)) {
                $r_code .= mk_value($fixer, $r_root, 'sourceAppellation', $source_appellation,
                $appellation_value_lang);
            }

            return $r_code;
        }
    );

    return $code;
};

1;