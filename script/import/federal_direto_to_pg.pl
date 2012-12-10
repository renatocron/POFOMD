#!/usr/bin/perl

use strict;
use warnings;
use POFOMD::Schema;

use Text::Unidecode;
use Text::CSV_XS;
use Text2URI;
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
my $ds_name = 'Governo Federal - Gastos diretos';

my $dataset = $rs_dataset->find_or_create(
    {
        nome => $ds_name,
        periodo =>
          $schema->resultset('Periodo')->find_or_create( { ano => $year } ),
        uri => $t->translate(join('-', 'federal-direto', $year))
    }
);

my (
$CODIGO_ORGAO_SUPERIOR, $NOME_ORGAO_SUPERIOR,
$CODIGO_ORGAO_SUBORDINADO, $NOME_ORGAO_SUBORDINADO,
$CODIGO_UNIDADE_GESTORA, $NOME_UNIDADE_GESTORA,
$CODIGO_GRUPO_DESPESA, $NOME_GRUPO_DESPESA,
$CODIGO_FUNCAO, $NOME_FUNCAO,
$CODIGO_SUBFUNCAO, $NOME_SUBFUNCAO,
$CODIGO_PROGRAMA, $NOME_PROGRAMA,
$CODIGO_ACAO, $NOME_ACAO,
$LINGUAGEM_CIDADA, $VALOR
);

my $csv = Text::CSV_XS->new(
    {
        sep_char => ';',
        allow_loose_quotes => 1,
        binary             => 1,
        verbatim           => 0,
        auto_diag          => 1,
        escape_char        => undef
    }
);

$csv->bind_columns(
    \$CODIGO_ORGAO_SUPERIOR, \$NOME_ORGAO_SUPERIOR,
    \$CODIGO_ORGAO_SUBORDINADO, \$NOME_ORGAO_SUBORDINADO,
    \$CODIGO_UNIDADE_GESTORA, \$NOME_UNIDADE_GESTORA,
    \$CODIGO_GRUPO_DESPESA, \$NOME_GRUPO_DESPESA,
    \$CODIGO_FUNCAO, \$NOME_FUNCAO,
    \$CODIGO_SUBFUNCAO, \$NOME_SUBFUNCAO,
    \$CODIGO_PROGRAMA, \$NOME_PROGRAMA,
    \$CODIGO_ACAO, \$NOME_ACAO,
    \$LINGUAGEM_CIDADA, \$VALOR
);

open my $fh, $ARGV[1] or die 'error';

my $line = 0;

while ( my $row = $csv->getline($fh) ) {
    $line++;
    next if $line==1 or !$VALOR;
    warn $line;
    $VALOR                    =~ s/\,/\./g;
    my $str = random_regex('\d\d\d\d\d\d\d\d\d\d\d\d');

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
                    codigo    => 'NAO-INFORMADO',
                    nome      => &remover_acentos('NAO-INFORMADO'),
                    documento => '0',
                    uri       => $t->translate( &remover_acentos('NAO-INFORMADO') )
                }
            ),

            despesa => $schema->resultset('Despesa')->find_or_create(
                {
                    codigo => $CODIGO_GRUPO_DESPESA,
                    nome   => &remover_acentos($NOME_GRUPO_DESPESA)
                }
            ),

            gestora => $schema->resultset('Gestora')->find_or_create(
                {
                    codigo => $CODIGO_UNIDADE_GESTORA,
                    nome   => $NOME_UNIDADE_GESTORA
                }
            ),

            pagamento => $schema->resultset('Pagamento')->find_or_create(
                {
                    numero_processo => "NAO-INFORMADO-$CODIGO_ACAO-$str",
                    numero_nota_empenho => 'NAO-INFORMADO',
                    tipo_licitacao  => 'NAO-INFORMADO',
                    valor_empenhado => 0,
                    valor_liquidado => $VALOR,
                    valor_pago_anos_anteriores => 0,
                }
            ),

            recurso => $schema->resultset('Recurso')->find_or_create(
                {
                    codigo => 'NAO-INFORMADO',
                    nome   => 'NAO-INFORMADO'
                }
            ),
            valor => $VALOR
        }
    );

    print "funcao, $NOME_FUNCAO\n";
    print "subfuncao, $NOME_SUBFUNCAO\n";
    print "programa, $NOME_PROGRAMA\n";
    print "acao, $NOME_ACAO\n";

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

