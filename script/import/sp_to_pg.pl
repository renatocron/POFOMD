#!/usr/bin/perl

use strict;
use warnings;
use POFOMD::Schema;

use Text::Unaccent;

use Text::Unidecode;
use Text::CSV_XS;
use Text2URI;

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
my $ds_name = 'Estado de São Paulo';

my $dataset = $rs_dataset->find_or_create(
    {
        nome => $ds_name,
        periodo =>
          $schema->resultset('Periodo')->find_or_create( { ano => $year } ),
        uri => $t->translate(join('-', 'estado-sao-paulo', $year))
    }
);

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

my $line = 0;
my $cache_inserting = {};
&load_from_database($_) for qw /Funcao Subfuncao Programa Acao Beneficiario Despesa Gestora Recurso/;

$rs->search({dataset_id => $dataset->id})->delete;

while ( my $row = $csv->getline($fh) ) {
    $line++;
    next if $CODIGO_FUNCAO eq 'CODIGO FUNCAO' or !$VALOR_LIQUIDADO;
    print "$line\n";
    $VALOR_EMPENHADO               =~ s/\,/\./g;
    $VALOR_LIQUIDADO               =~ s/\,/\./g;
    $VALOR_PAGO_DE_ANOS_ANTERIORES =~ s/\,/\./g;
    $VALOR_LIQUIDADO                    =~ s/\,/\./g;

    my $obj = $rs->create(
        {
            dataset_id => $dataset->id,

            &cache_or_create(funcao => 'Funcao',
                { codigo => $CODIGO_FUNCAO, nome => $NOME_FUNCAO }
            ),

            &cache_or_create(subfuncao => 'Subfuncao',
                { codigo => $CODIGO_SUBFUNCAO, nome => $NOME_SUBFUNCAO }
            ),

            &cache_or_create(programa => 'Programa',
                {
                    codigo => $CODIGO_PROGRAMA,
                    nome   => &remover_acentos($NOME_PROGRAMA)
                }
            ),

            &cache_or_create(acao => 'Acao',
                {
                    codigo => $CODIGO_ACAO,
                    nome   => &remover_acentos($NOME_ACAO)
                }
            ),

            &cache_or_create(beneficiario => 'Beneficiario',
                {
                    codigo    => $CODIGO_CREDOR,
                    nome      => &remover_acentos($NOME_CREDOR),
                    documento => '0',
                    uri       => $t->translate( &remover_acentos($NOME_CREDOR) )
                }
            ),

            &cache_or_create(despesa => 'Despesa',
                {
                    codigo => $CODIGO_GRUPO_DE_DESPESA,
                    nome   => &remover_acentos($NOME_GRUPO_DE_DESPESA)
                }
            ),

            &cache_or_create(gestora => 'Gestora',
                {
                    codigo => $CODIGO_UNIDADE_GESTORA,
                    nome   => $NOME_UNIDADE_GESTORA
                }
            ),

            pagamento => $schema->resultset('Pagamento')->create(
                {
                    numero_processo => &remover_acentos($NUMERO_PROCESSO),
                    numero_nota_empenho =>
                      &remover_acentos($NUMERO_NOTA_DE_EMPENHO),
                    tipo_licitacao  => &remover_acentos($TIPO_LICITACAO),
                    valor_empenhado => $VALOR_EMPENHADO,
                    valor_liquidado => $VALOR_LIQUIDADO,
                    valor_pago_anos_anteriores =>
                      $VALOR_PAGO_DE_ANOS_ANTERIORES || 0
                }
            ),

            &cache_or_create(recurso => 'Recurso',
                {
                    codigo => &remover_acentos($CODIGO_FONTE_DE_RECURSOS),
                    nome   => &remover_acentos($NOME_FONTE_DE_RECURSOS)
                }
            ),
            valor => $VALOR_LIQUIDADO
        }
    );

    #print "funcao, $NOME_FUNCAO\n";
    #print "subfuncao, $NOME_SUBFUNCAO\n";
    #print "programa, $NOME_PROGRAMA\n";
    #print "acao, $NOME_ACAO\n";
    #print "credor, $NOME_CREDOR\n\n";

}

print "done\n";
close $fh;



sub load_from_database {
    my ($campo) = @_;

    my $campo_lc = lc $campo;
    my $rs = $schema->resultset($campo);
    my $r;
    $cache_inserting->{$campo_lc}{$r->codigo} = $r->id while ($r = $rs->next);
}

sub cache_or_create {
    my ($campo, $set, $info) = @_;

    my $codigo = $info->{codigo};
    my $id;

    if (exists $cache_inserting->{$campo}{$codigo}){

        $id = $cache_inserting->{$campo}{$codigo};

    }else{
        my $obj = $schema->resultset($set)->create($info);

        $cache_inserting->{$campo}{$codigo} = $id = $obj->id;
    };

    return ($campo . '_id' => $id);
}

sub remover_acentos {
    my $var = shift;
    $var = unac_string('UTF-8', $var);
    return $var;
}

