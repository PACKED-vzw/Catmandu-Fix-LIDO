package Catmandu::Fix::LIDO::ID;

use strict;

use Exporter qw(import);
use Data::Dumper qw(Dumper);

use Catmandu::Fix::LIDO::Utility qw(walk declare_source);

our @EXPORT_OK = qw(mk_id);

sub mk_id {
	my ($fixer, $root, $path, $id, $source, $label, $type) = @_;

	my $new_path = $fixer->split_path($path);
    push @$new_path, '$append';
    my $code = '';

	my $f_id = $fixer->generate_var();
	$code .= "my ${f_id};";
	$code .= declare_source($fixer, $id, $f_id);

	my $i_root = $fixer->var;
	if (defined($root)) {
		$i_root = $root;
	}

    $code .= $fixer->emit_create_path(
		$i_root,
		$new_path,
		sub {
			my $r_root = shift;
			my $r_code = '';
			$r_code .= "${r_root} = {"
				."'_' => ${f_id},"
				."'type' => '".$type."',";
			if (defined($source)) {
				$r_code .= "'source' => '".$source."',";
			}
			$r_code .= "'label' => '".$label."'"
				."};";
			return $r_code;
		}
	);

    return $code;
};

1;