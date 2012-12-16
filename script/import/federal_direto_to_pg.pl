#!/usr/bin/perl

use strict;
use warnings;
use POFOMD::Schema;

use Text::Unaccent;

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

open my $fh, '<:encoding(iso-8859-1)', $ARGV[1] or die 'error';

my $line = 0;


my $cache_inserting = {};
&load_from_database($_) for qw /Funcao Subfuncao Programa Acao Beneficiario Despesa Gestora Recurso/;


$rs->search({dataset_id => $dataset->id})->delete;


while ( my $row = $csv->getline($fh) ) {
    $line++;
    next if $line==1 or !$VALOR;
    print "$line\n";
    $VALOR                    =~ s/\,/\./g;
    my $str = random_regex('\d\d\d\d\d\d\d\d\d\d\d\d');

    my $obj = $rs->create(
        {
            dataset_id => $dataset->id,

            &cache_or_create('funcao', 'Funcao',
                { codigo => $CODIGO_FUNCAO, nome => $NOME_FUNCAO }
            ),

            &cache_or_create('subfuncao', 'Subfuncao',
                { codigo => $CODIGO_SUBFUNCAO, nome => $NOME_SUBFUNCAO }
            ),

            &cache_or_create('programa', 'Programa',
                {
                    codigo => $CODIGO_PROGRAMA,
                    nome   => &remover_acentos($NOME_PROGRAMA)
                }
            ),

            &cache_or_create('acao', 'Acao',
                {
                    codigo => $CODIGO_ACAO,
                    nome   => &remover_acentos($NOME_ACAO)
                }
            ),

            &cache_or_create('beneficiario', 'Beneficiario',
                {
                    codigo    => 'NAO-INFORMADO',
                    nome      => &remover_acentos('NAO-INFORMADO'),
                    documento => '0',
                    uri       => $t->translate( &remover_acentos('NAO-INFORMADO') )
                }
            ),

            &cache_or_create('despesa', 'Despesa',
                {
                    codigo => $CODIGO_GRUPO_DESPESA,
                    nome   => &remover_acentos($NOME_GRUPO_DESPESA)
                }
            ),

            &cache_or_create('gestora', 'Gestora',
                {
                    codigo => $CODIGO_UNIDADE_GESTORA,
                    nome   => $NOME_UNIDADE_GESTORA
                }
            ),


            pagamento => $schema->resultset('Pagamento')->create(
                {
                    numero_processo => "NAO-INFORMADO-$CODIGO_ACAO-$str",
                    numero_nota_empenho => 'NAO-INFORMADO',
                    tipo_licitacao  => 'NAO-INFORMADO',
                    valor_empenhado => 0,
                    valor_liquidado => $VALOR,
                    valor_pago_anos_anteriores => 0,
                }
            ),

            &cache_or_create('recurso', 'Recurso',
                {
                    codigo => 'NAO-INFORMADO',
                    nome   => 'NAO-INFORMADO'
                }
            ),
            valor => $VALOR
        }
    );

#    print "funcao, $NOME_FUNCAO\n";
#    print "subfuncao, $NOME_SUBFUNCAO\n";
#    print "programa, $NOME_PROGRAMA\n";
#    print "acao, $NOME_ACAO\n";

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
