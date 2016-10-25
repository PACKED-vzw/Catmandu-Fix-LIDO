requires 'perl', '5.10.1';

on test => sub {
    requires 'Test::More', '0.96';
};

requires 'Catmandu', '>=1.0201';
requires 'Catmandu::XML', '>=0.16';
requires 'String::Util', '>=1.26';
requires 'Data::Dumper', '>=2.161';
requires 'Catmandu::Exporter::LIDO', '>=0.03';
requires 'Moo', '1.0';
