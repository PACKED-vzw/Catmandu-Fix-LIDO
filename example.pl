#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Catmandu;
use Data::Dumper;


my $importer = Catmandu->importer('XML', file => 'adlib_example.xml', data_path => 'recordList.record.*');
my $exporter = Catmandu->exporter('LIDO');
my $fixer = Catmandu->fixer('msk.fix');

$exporter->add_many(
  $fixer->fix($importer)
);
$exporter->commit;
