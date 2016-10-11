package Catmandu::Fix::LIDO::DescriptiveNote;

use Catmandu::Fix::LIDO::Utility qw(walk declare_source);
use Catmandu::Fix::LIDO::Value qw(mk_value);

use strict;

use Exporter qw(import);

our @EXPORT_OK = qw(mk_descriptive_note);

sub mk_descriptive_note{
    my ($fixer, $root, $path, $value, $lang, $label) = @_;
    my $code = '';

    my $new_path = $fixer->split_path($path);

    my $v_root = $fixer->var;
    if (defined($root)) {
        $v_root = $root;
    }

    my $f_value = $fixer->generate_var();
    $code .= "my ${f_value};";
    $code .= declare_source($fixer, $value, $f_value);

    $code .= $fixer->emit_create_path(
        $v_root,
        $new_path,
        sub {
            my $r_root = shift;
            my $r_code = '';

            $r_code .= $fixer->emit_create_path(
                $r_root,
                ['$append', 'descriptiveNoteValue', '$append'],
                sub {
                    my $dn_root = shift;

                    my $dn_code = '';

                    $dn_code .= "${dn_root} = {";

                    if (defined($lang)) {
                        $dn_code .= "'lang' => '".$lang."',";
                    }

                    if (defined($label)) {
                        $dn_code .= "'label' => '".$label."',";
                    }

                    $dn_code .= "'_' => ${f_value}";

                    $dn_code .= "};";

                    return $dn_code;
                }
            );

            return $r_code;
        }
    );

    return $code;
}

1;