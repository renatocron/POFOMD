#!/usr/bin/perl

use strict;
use warnings;
use POFOMD::Schema;

use Text::Unidecode;
use Text::CSV_XS;
use Text2URI;
use String::Numeric qw/is_float/;
use String::Random qw(random_regex random_string);

my $t = new Text2URI();

my $schema = POFOMD::Schema->connect( "dbi:Pg:host=localhost;dbname=pofomd",
    "postgres", "" );
my $rs         = $schema->resultset('Gasto');
my $rs_dataset = $schema->resultset('Dataset');

if ( scalar(@ARGV) != 2 ) {
    print "Use $0 [year] [dataset.csv]\n";
    exit;
}

my $year    = $ARGV[0];
my $ds_name = 'Município de São Paulo';

my $dataset = $rs_dataset->find_or_create(
    {
        nome => $ds_name,
        periodo =>
          $schema->resultset('Periodo')->find_or_create( { ano => $year } ),
        uri => $t->translate( join( '-', 'municipio-sao-paulo', $year ) )
    }
);

my (
$Exercicio,
$Cod_Empresa,
$Empresa,
$Cod_Orgao,
$Orgao,
$Cod_Unidade,
$Unidade,
$Cod_Funcao,
$Funcao,
$Cod_Subfuncao,
$Subfuncao,
$Cod_Programa_de_Governo,
$Programa_de_Governo,
$Cod_Projeto_Atividade,
$Projeto_Atividade,
$Cod_Elemento_de_Despesa,
$Elemento_de_Despesa,
$Cod_Fonte_de_Recurso,
$Fonte_de_Recurso,
$Orcado,
$Atualizado,
$Empenhado,
$Liquidado,
$Pago
);

my $csv = Text::CSV_XS->new(
    {
        sep_char            => ',',
        allow_loose_quotes => 1,
        binary             => 1,
        verbatim           => 1,
        auto_diag          => 1,
        escape_char        => undef
    }
);

$csv->bind_columns(
\$Exercicio,
\$Cod_Empresa,
\$Empresa,
\$Cod_Orgao,
\$Orgao,
\$Cod_Unidade,
\$Unidade,
\$Cod_Funcao,
\$Funcao,
\$Cod_Subfuncao,
\$Subfuncao,
\$Cod_Programa_de_Governo,
\$Programa_de_Governo,
\$Cod_Projeto_Atividade,
\$Projeto_Atividade,
\$Cod_Elemento_de_Despesa,
\$Elemento_de_Despesa,
\$Cod_Fonte_de_Recurso,
\$Fonte_de_Recurso,
\$Orcado,
\$Atualizado,
\$Empenhado,
\$Liquidado,
\$Pago
);

open my $fh, $ARGV[1] or die 'error';

my $line = 0;

while ( my $row = $csv->getline($fh) ) {
    $line++;
    next if $line==1 or !$Liquidado;
    next if $Exercicio;
    warn $Liquidado;
    $Liquidado =~ s/\,//g;
    $Liquidado =~ s/\ //g;
    $Liquidado =~ s/R\$//g;
    $Empenhado =~ s/\,//g;
    $Empenhado =~ s/R\$//g;

    warn $line . "- $Liquidado";
    next if $Liquidado =~ '-' or $Empenhado =~ '-';
    
    my $str = random_regex('\d\d\d\d\d\d\d\d\d\d\d\d');
    my $obj = $rs->create(
        {
            dataset_id => $dataset->id,

            funcao => $schema->resultset('Funcao')->find_or_create(
                { codigo => $Cod_Funcao, nome => $Funcao }
            ),

            subfuncao => $schema->resultset('Subfuncao')->find_or_create(
                { codigo => $Cod_Subfuncao, nome => $Subfuncao }
            ),

            programa => $schema->resultset('Programa')->find_or_create(
                {
                    codigo => $Cod_Programa_de_Governo,
                    nome   => &remover_acentos($Programa_de_Governo)
                }
            ),

            acao => $schema->resultset('Acao')->find_or_create(
                {
                    codigo => $Cod_Projeto_Atividade,
                    nome   => &remover_acentos($Projeto_Atividade)
                }
            ),

            beneficiario => $schema->resultset('Beneficiario')->find_or_create(
                {
                    codigo    => 'NAO-INFORMADO',
                    nome      => &remover_acentos('NAO INFORMADO'),
                    documento => '0',
                    uri       => $t->translate( &remover_acentos('NAO-INFORMADO') )
                }
            ),

            despesa => $schema->resultset('Despesa')->find_or_create(
                {
                    codigo => $Cod_Elemento_de_Despesa,
                    nome   => &remover_acentos($Elemento_de_Despesa)
                }
            ),

            gestora => $schema->resultset('Gestora')->find_or_create(
                {
                    codigo => $Cod_Unidade,
                    nome   => &remover_acentos($Unidade)
                }
            ),
            pagamento => $schema->resultset('Pagamento')->find_or_create(
                {
                    numero_processo => "NAO-INFORMADO-$Cod_Projeto_Atividade-$str",
                    numero_nota_empenho => 'NAO-INFORMADO',
                    tipo_licitacao  => 'NAO-INFORMADO',
                    valor_empenhado => $Empenhado,
                    valor_liquidado => $Liquidado,
                    valor_pago_anos_anteriores => 0
                }
            ),

            recurso => $schema->resultset('Recurso')->find_or_create(
                {
                    codigo => $Cod_Fonte_de_Recurso,
                    nome   => &remover_acentos($Fonte_de_Recurso)
                }
            ),
            valor => $Liquidado
        }
    );

    print "funcao, $Funcao\n";
    print "subfuncao, $Subfuncao\n";
    print "programa, $Programa_de_Governo\n";
    print "acao, $Projeto_Atividade\n";
    print "credor, NAO-INFORMADO\n\n";

}

print "done\n";
close $fh;

sub remover_acentos {
    my $var = shift;
    $var = unidecode($var);
    map {
        s/Á/A/g;
        s/À/A/g;
        s/Ã/A/g;
        s/Ä/A/g;
        s/Â/A/g;
        s/á/a/g;
        s/à/a/g;
        s/ã/a/g;
        s/ä/a/g;
        s/â/a/g;

        s/É/E/g;
        s/È/E/g;
        s/Ë/E/g;
        s/Ê/E/g;
        s/é/e/g;
        s/è/e/g;
        s/ë/e/g;
        s/ê/e/g;

        s/Í/I/g;
        s/Ì/I/g;
        s/Ï/I/g;
        s/Î/I/g;
        s/í/i/g;
        s/ì/i/g;
        s/ï/i/g;
        s/î/i/g;

        s/Ó/O/g;
        s/Ò/O/g;
        s/Õ/O/g;
        s/Ö/O/g;
        s/Ô/O/g;
        s/ó/o/g;
        s/ò/o/g;
        s/õ/o/g;
        s/ö/o/g;
        s/ô/o/g;

        s/Ú/U/g;
        s/Ù/U/g;
        s/Ü/U/g;
        s/Û/U/g;
        s/ú/u/g;
        s/ù/u/g;
        s/ü/u/g;
        s/û/u/g;

        s/ç/c/;
        s/Ç/C/;
    } $var;

    return $var;
}

