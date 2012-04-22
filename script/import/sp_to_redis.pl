#!/usr/bin/perl

# http://www.fazenda.sp.gov.br/download/default.shtm

use strict;
use warnings;

use Redis;
use Text::CSV_XS;
my ($ANO_DE_REFERENCIA,           $CODIGO_ORGAO,                $NOME_ORGAO,
    $CODIGO_UNIDADE_ORCAMENTARIA, $NOME_UNIDADE_ORCAMENTARIA,   $CODIGO_UNIDADE_GESTORA,
    $NOME_UNIDADE_GESTORA,        $CODIGO_CATEGORIA_DE_DESPESA, $NOME_CATEGORIA_DE_DESPESA,
    $CODIGO_GRUPO_DE_DESPESA,     $NOME_GRUPO_DE_DESPESA,       $CODIGO_MODALIDADE,
    $NOME_MODALIDADE,             $CODIGO_ELEMENTO_DE_DESPESA,  $NOME_ELEMENTO_DE_DESPESA,
    $CODIGO_ITEM_DE_DESPESA,      $NOME_ITEM_DE_DESPESA,        $CODIGO_FUNCAO,
    $NOME_FUNCAO,                 $CODIGO_SUBFUNCAO,            $NOME_SUBFUNCAO,
    $CODIGO_PROGRAMA,             $NOME_PROGRAMA,               $CODIGO_PROGRAMA_DE_TRABALHO,
    $NOME_PROGRAMA_DE_TRABALHO,   $CODIGO_FONTE_DE_RECURSOS,    $NOME_FONTE_DE_RECURSOS,
    $NUMERO_PROCESSO,             $NUMERO_NOTA_DE_EMPENHO,      $CODIGO_CREDOR,
    $NOME_CREDOR,                 $CODIGO_ACAO,                 $NOME_ACAO,
    $TIPO_LICITACAO,              $VALOR_EMPENHADO,             $VALOR_LIQUIDADO,
    $VALOR_PAGO,                  $VALOR_PAGO_DE_ANOS_ANTERIORES
);

my $redis = new Redis;
$redis->select('sp2011');
my $csv = Text::CSV_XS->new( { binary => 1 } );

$csv->bind_columns(
    \$ANO_DE_REFERENCIA,           \$CODIGO_ORGAO,                \$NOME_ORGAO,
    \$CODIGO_UNIDADE_ORCAMENTARIA, \$NOME_UNIDADE_ORCAMENTARIA,   \$CODIGO_UNIDADE_GESTORA,
    \$NOME_UNIDADE_GESTORA,        \$CODIGO_CATEGORIA_DE_DESPESA, \$NOME_CATEGORIA_DE_DESPESA,
    \$CODIGO_GRUPO_DE_DESPESA,     \$NOME_GRUPO_DE_DESPESA,       \$CODIGO_MODALIDADE,
    \$NOME_MODALIDADE,             \$CODIGO_ELEMENTO_DE_DESPESA,  \$NOME_ELEMENTO_DE_DESPESA,
    \$CODIGO_ITEM_DE_DESPESA,      \$NOME_ITEM_DE_DESPESA,        \$CODIGO_FUNCAO,
    \$NOME_FUNCAO,                 \$CODIGO_SUBFUNCAO,            \$NOME_SUBFUNCAO,
    \$CODIGO_PROGRAMA,             \$NOME_PROGRAMA,               \$CODIGO_PROGRAMA_DE_TRABALHO,
    \$NOME_PROGRAMA_DE_TRABALHO,   \$CODIGO_FONTE_DE_RECURSOS,    \$NOME_FONTE_DE_RECURSOS,
    \$NUMERO_PROCESSO,             \$NUMERO_NOTA_DE_EMPENHO,      \$CODIGO_CREDOR,
    \$NOME_CREDOR,                 \$CODIGO_ACAO,                 \$NOME_ACAO,
    \$TIPO_LICITACAO,              \$VALOR_EMPENHADO,             \$VALOR_LIQUIDADO,
    \$VALOR_PAGO,                  \$VALOR_PAGO_DE_ANOS_ANTERIORES
);

open my $fh, $ARGV[0] or die 'error';

$redis->flushall;
print "start..\n";

while ( my $row = $csv->getline($fh) ) {
    next if $CODIGO_FUNCAO eq 'CODIGO FUNCAO' or !$VALOR_PAGO;

    my $key = join('_', $CODIGO_FUNCAO, $CODIGO_SUBFUNCAO, $CODIGO_PROGRAMA,
        $CODIGO_ACAO, $CODIGO_CREDOR);

    my $key_funcao = "FUNCAO_$CODIGO_FUNCAO";
    my $key_subfuncao = "SUBFUNCAO_$CODIGO_SUBFUNCAO";
    my $key_programa = "PROGRAMA_$CODIGO_PROGRAMA";
    my $key_acao = "ACAO_$CODIGO_ACAO";
    my $key_credor = "CREDOR_$CODIGO_CREDOR";

    my $value = $VALOR_PAGO;
    $value =~ s/\,/\./g;
    my $redis_value;
    if ($redis_value = $redis->get($key)) {
        #$redis->incrbyfloat($key, $value);
        $redis->set($key, $value + $redis_value);
    } else {
        $redis->set($key, $value);
    }
    
    $redis->set($key_funcao, $NOME_FUNCAO);
    $redis->set($key_subfuncao, $NOME_SUBFUNCAO);
    $redis->set($key_programa, $NOME_PROGRAMA);
    $redis->set($key_acao, $NOME_ACAO);
    $redis->set($key_credor, $NOME_CREDOR);

    #print "$key, $value\n";
    #print "$key_funcao, $NOME_FUNCAO\n";
    #print "$key_subfuncao, $NOME_SUBFUNCAO\n";
    #print "$key_programa, $NOME_PROGRAMA\n";
    #print "$key_acao, $NOME_ACAO\n";
    #print "$key_credor, $NOME_CREDOR\n\n";

}
my  ($cde, $str, $pos) = $csv->error_diag ();
print "$cde\n";
print "$str\n";
print "$pos\n";

#$csv->eof or $csv->error_diag();
close $fh;

