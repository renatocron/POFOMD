#!/usr/bin/perl

use strict;
use warnings;
use POFOMD::Schema;

#use Text::Iconv;
use Text::Unidecode;
use Text::CSV_XS;

my $schema = POFOMD::Schema->connect( "dbi:Pg:host=localhost;dbname=pofomd",
    "postgres", "" );
my $rs         = $schema->resultset('Gasto');
my $rs_dataset = $schema->resultset('Dataset');

if ( scalar(@ARGV) != 2 ) {
    print "Use $0 [year] [dataset.csv]\n";
    exit;
}

my $year = $ARGV[0];
my $dataset =
  $rs_dataset->find_or_create( { nome => 'Sao Paulo', ano => $year } );

my (
    $ANO_DE_REFERENCIA,         $CODIGO_ORGAO,
    $NOME_ORGAO,                $CODIGO_UNIDADE_ORCAMENTARIA,
    $NOME_UNIDADE_ORCAMENTARIA, $CODIGO_UNIDADE_GESTORA,
    $NOME_UNIDADE_GESTORA,      $CODIGO_CATEGORIA_DE_DESPESA,
    $NOME_CATEGORIA_DE_DESPESA, $CODIGO_GRUPO_DE_DESPESA,
    $NOME_GRUPO_DE_DESPESA,     $CODIGO_MODALIDADE,
    $NOME_MODALIDADE,           $CODIGO_ELEMENTO_DE_DESPESA,
    $NOME_ELEMENTO_DE_DESPESA,  $CODIGO_ITEM_DE_DESPESA,
    $NOME_ITEM_DE_DESPESA,      $CODIGO_FUNCAO,
    $NOME_FUNCAO,               $CODIGO_SUBFUNCAO,
    $NOME_SUBFUNCAO,            $CODIGO_PROGRAMA,
    $NOME_PROGRAMA,             $CODIGO_PROGRAMA_DE_TRABALHO,
    $NOME_PROGRAMA_DE_TRABALHO, $CODIGO_FONTE_DE_RECURSOS,
    $NOME_FONTE_DE_RECURSOS,    $NUMERO_PROCESSO,
    $NUMERO_NOTA_DE_EMPENHO,    $CODIGO_CREDOR,
    $NOME_CREDOR,               $CODIGO_ACAO,
    $NOME_ACAO,                 $TIPO_LICITACAO,
    $VALOR_EMPENHADO,           $VALOR_LIQUIDADO,
    $VALOR_PAGO,                $VALOR_PAGO_DE_ANOS_ANTERIORES
);

my $csv = Text::CSV_XS->new(
    {
        allow_loose_quotes => 1,
        binary             => 1,
        verbatim           => 0,
        auto_diag          => 1,
        escape_char        => undef
    }
);

$csv->bind_columns(
    \$ANO_DE_REFERENCIA,         \$CODIGO_ORGAO,
    \$NOME_ORGAO,                \$CODIGO_UNIDADE_ORCAMENTARIA,
    \$NOME_UNIDADE_ORCAMENTARIA, \$CODIGO_UNIDADE_GESTORA,
    \$NOME_UNIDADE_GESTORA,      \$CODIGO_CATEGORIA_DE_DESPESA,
    \$NOME_CATEGORIA_DE_DESPESA, \$CODIGO_GRUPO_DE_DESPESA,
    \$NOME_GRUPO_DE_DESPESA,     \$CODIGO_MODALIDADE,
    \$NOME_MODALIDADE,           \$CODIGO_ELEMENTO_DE_DESPESA,
    \$NOME_ELEMENTO_DE_DESPESA,  \$CODIGO_ITEM_DE_DESPESA,
    \$NOME_ITEM_DE_DESPESA,      \$CODIGO_FUNCAO,
    \$NOME_FUNCAO,               \$CODIGO_SUBFUNCAO,
    \$NOME_SUBFUNCAO,            \$CODIGO_PROGRAMA,
    \$NOME_PROGRAMA,             \$CODIGO_PROGRAMA_DE_TRABALHO,
    \$NOME_PROGRAMA_DE_TRABALHO, \$CODIGO_FONTE_DE_RECURSOS,
    \$NOME_FONTE_DE_RECURSOS,    \$NUMERO_PROCESSO,
    \$NUMERO_NOTA_DE_EMPENHO,    \$CODIGO_CREDOR,
    \$NOME_CREDOR,               \$CODIGO_ACAO,
    \$NOME_ACAO,                 \$TIPO_LICITACAO,
    \$VALOR_EMPENHADO,           \$VALOR_LIQUIDADO,
    \$VALOR_PAGO,                \$VALOR_PAGO_DE_ANOS_ANTERIORES
);

open my $fh, $ARGV[1] or die 'error';

my $line   = 0;

while ( my $row = $csv->getline($fh) ) {
    $line++;
    next if $CODIGO_FUNCAO eq 'CODIGO FUNCAO' or !$VALOR_PAGO;
    warn $line;
    $VALOR_EMPENHADO               =~ s/\,/\./g;
    $VALOR_LIQUIDADO               =~ s/\,/\./g;
    $VALOR_PAGO_DE_ANOS_ANTERIORES =~ s/\,/\./g;
    $VALOR_PAGO                    =~ s/\,/\./g;

    my $obj = $rs->create(
        {
            dataset_id => $dataset->id,

            funcao => $schema->resultset('Funcao')->find_or_create(
                { codigo => $CODIGO_FUNCAO, nome => $NOME_FUNCAO }
            ),

            subfuncao => $schema->resultset('Subfuncao')->find_or_create(
                { codigo => $CODIGO_SUBFUNCAO, nome => $NOME_SUBFUNCAO }
            ),

            programa => $schema->resultset('Programa')->find_or_create(
                {
                    codigo => $CODIGO_PROGRAMA,
                    nome   => &remover_acentos($NOME_PROGRAMA)
                }
            ),

            acao => $schema->resultset('Acao')->find_or_create(
                {
                    codigo => $CODIGO_ACAO,
                    nome   => &remover_acentos($NOME_ACAO)
                }
            ),

            beneficiario => $schema->resultset('Beneficiario')->find_or_create(
                {
                    codigo    => $CODIGO_CREDOR,
                    nome      => &remover_acentos($NOME_CREDOR),
                    documento => '0'
                }
            ),

            despesa => $schema->resultset('Despesa')->find_or_create(
                {
                    codigo => $CODIGO_GRUPO_DE_DESPESA,
                    nome   => &remover_acentos($NOME_GRUPO_DE_DESPESA)
                }
            ),

            pagamento => $schema->resultset('Pagamento')->find_or_create(
                {
                    tipo_licitacao  => &remover_acentos($TIPO_LICITACAO),
                    valor_empenhado => $VALOR_EMPENHADO,
                    valor_liquidado => $VALOR_LIQUIDADO,
                    valor_pago_anos_anteriores =>
                      $VALOR_PAGO_DE_ANOS_ANTERIORES || 0
                }
            ),
            valor_pago => $VALOR_PAGO
        }
    );

    print "funcao, $NOME_FUNCAO\n";
    print "subfuncao, $NOME_SUBFUNCAO\n";
    print "programa, $NOME_PROGRAMA\n";
    print "acao, $NOME_ACAO\n";
    print "credor, $NOME_CREDOR\n\n";

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


