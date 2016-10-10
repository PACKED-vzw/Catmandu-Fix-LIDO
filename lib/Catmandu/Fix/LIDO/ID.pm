package Catmandu::Fix::LIDO::ID;

use strict;

use Exporter qw(import);
use Data::Dumper qw(Dumper);

use Catmandu::Fix::LIDO::Utility qw(walk);

our @EXPORT_OK = qw(mk_id);

sub mk_id {
    my ($fixer, $path, $cm_value, $source, $label, $type) = @_;
    push @$path, '$append';
    my $perl = '';

    $perl .= $fixer->emit_create_path(
		$fixer->var,
		$path,
		sub {
			my $path_var = shift;
			my $code = '';
			$code .= "${path_var} = {"
				."'_' => ${cm_value},"
				."'type' => '".$type."',";
			if (defined($source)) {
				$code .= "'source' => '".$source."',";
			}
			$code .= "'label' => '".$label."'"
				."};";
			return $code;
		}
	);

    return $perl;
};

1;