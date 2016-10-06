package Catmandu::Fix::LIDO::Term;

use Catmandu::Fix::LIDO::Utility qw(walk declare_source);

use strict;

use Exporter qw(import);

our @EXPORT_OK = qw(mk_term);

#has path      => ( fix_arg => 1);
#has term      => ( fix_arg => 1 );
#has conceptid => ( fix_opt => 1 );
#has lang      => ( fix_opt => 1, default => sub { 'en' } );
#has pref      => ( fix_opt => 1, default => sub { 'preferred' } );
#has source    => ( fix_opt => 1, default => sub { 'AAT' } );
#has type      => ( fix_opt => 1, default => sub { 'global' } );

sub mk_term {
    my ($fixer, $path, $term, $conceptid, $lang, $pref, $source, $type) = @_;

    my $code = '';

    my $h = $fixer->generate_var();
    my $new_path = $fixer->split_path($path);
    $code .= "my ${h} = {};";

    ##
    # term
    my $f_term = $fixer->generate_var();
    $code .= "my ${f_term};";
    $code .= declare_source($fixer, $term, $f_term);

    ##
    # Create the term for Lido::XML ad the correct path
    $code .= $fixer->emit_create_path(
        $fixer->var,
        $new_path,
        sub {
            my $p_root = shift;
            my $p_code = '';

            $p_code .= $fixer->emit_create_path(
                        $p_root,
                        ['term', '$append'],
                        sub {
                            my $term_root = shift;
                            return "${term_root} = {"
                            ."'_' => ${f_term},"
                            ."'lang' => '". $lang."',"
                            ."'pref' => '".$pref."'"
                            ."}";
                        }
                    );
            ##
            # conceptID
            if ( $conceptid ) {
                my $f_conceptid = $fixer->generate_var();
                $p_code .= "my ${f_conceptid};";
                $p_code .= declare_source($fixer, $conceptid, $f_conceptid);
                ##
                # Create the conceptID for Lido::XML
                $p_code .= $fixer->emit_create_path(
                    $p_root, # At the root level, use a bind or a move_field if you want it someplace else
                    ['conceptID', '$append'],
                    sub {
                        my $concept_root = shift;
                        my $c_code = '';
                        $c_code .= "${concept_root} = {"
                        ."'_' => ${f_conceptid},"
                        ."'pref' => '".$pref."',"
                        ."'type' => '".$type."'"
                        ."};";
                        return $c_code;
                    }
                );
            }

            return $p_code;
        }
    );

    return $code;
}

1;