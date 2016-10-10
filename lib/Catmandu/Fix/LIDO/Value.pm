package Catmandu::Fix::LIDO::Value;

use Catmandu::Fix::LIDO::Utility qw(walk declare_source);

use strict;

use Exporter qw(import);

our @EXPORT_OK = qw(mk_value);

sub mk_value {
    my ($fixer, $root, $path, $value, $lang, $pref, $label, $type) = @_;

    my $new_path = $fixer->split_path($path);
    my $code = '';
    my $f_val = $fixer->generate_var();
    $code .= "my ${f_val};";
    $code .= declare_source($fixer, $value, $f_val);

    my $v_root = $fixer->var;
    if (defined ($root)) {
        $v_root = $root;
    }

    $code .= $fixer->emit_create_path(
        $v_root,
        $new_path,
        sub {
            my $r_root = shift;
            my $r_code = '';

            $r_code .= $fixer->emit_create_path(
                $r_root,
                ['$append'],
                sub {
                    my $a_root = shift;
                    my $a_code = '';
                    $a_code .= "${a_root} = {";
                    if (defined($lang)) {
                        $a_code .= "'lang' => '".$lang."',";
                    }
                    if (defined ($pref)) {
                        $a_code .= "'pref' => '".$pref."',";
                    }
                    if (defined ($label)) {
                        $a_code .= "'label' => '".$label."',";
                    }
                    if (defined ($type)) {
                        $a_code .= "'type' => '".$type."',";
                    }
                    $a_code .= "'_' => ${f_val}";
                    $a_code .= "};";
                    return $a_code;
                }
            );

            return $r_code;
        }
    );

    return $code;
}

1;