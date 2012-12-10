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
    $DataInicial,                 $DataFinal,
    $Cd_AnoExecucao,              $Cd_Exercicio,
    $Cd_Dotacao_Id,               $Cd_Exerc_Empresa_Id,
    $Administracao,               $Cd_Orgao,
    $Sigla_Orgao,                 $Ds_Orgao,
    $Cd_Unidade,                  $Ds_Unidade,
    $Cd_Funcao,                   $Ds_Funcao,
    $Cd_SubFuncao,                $Ds_SubFuncao,
    $Cd_Programa,                 $Ds_Programa,
    $Tp_Projeto_Atividade,        $Cd_Projeto_Atividade,
    $PA,                          $PAPA,
    $ProjetoAtividade,            $Ds_Projeto_Atividade,
    $Cd_Despesa,                  $Ds_Despesa,
    $Categoria_Despesa,           $Ds_Categoria,
    $Grupo_Despesa,               $Ds_Grupo,
    $Cd_Modalidade,               $Ds_Modalidade,
    $Cd_Elemento,                 $Cd_Fonte,
    $Ds_Fonte,                    $Sld_Orcado_Ano,
    $Vl_Correcao_Dotac,           $Vl_Deflacao_Dotac,
    $Vl_Suplementado,             $Vl_Reduzido,
    $Vl_SuplementadoLiquido,      $Vl_Atualizado,
    $Vl_SuplementadoEmTramitacao, $Vl_ReduzidoEmTramitacao,
    $Vl_Congelado,                $Vl_Descongelado,
    $Vl_CongeladoLiquido,         $Vl_Reservado,
    $Vl_Cancelado,                $Vl_ReservadoLiquido,
    $Vl_Empenhado,                $Vl_Anulado,
    $Vl_EmpenhadoLiquido,         $Vl_Liquidado,
    $Vl_Pago,                     $Jan_Prev,
    $Jan_Real,                    $Jan_Pag,
    $Fev_Prev,                    $Fev_Real,
    $Fev_Pag,                     $Mar_Prev,
    $Mar_Real,                    $Mar_Pag,
    $Abr_Prev,                    $Abr_Real,
    $Abr_Pag,                     $Mai_Prev,
    $Mai_Real,                    $Mai_Pag,
    $Jun_Prev,                    $Jun_Real,
    $Jun_Pag,                     $Jul_Prev,
    $Jul_Real,                    $Jul_Pag,
    $Ago_Prev,                    $Ago_Real,
    $Ago_Pag,                     $Set_Prev,
    $Set_Real,                    $Set_Pag,
    $Out_Prev,                    $Out_Real,
    $Out_Pag,                     $Nov_Prev,
    $Nov_Real,                    $Nov_Pag,
    $Dez_Prev,                    $Dez_Real,
    $Dez_Pag,                     $DataExtracao
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
    \$DataInicial,                 \$DataFinal,
    \$Cd_AnoExecucao,              \$Cd_Exercicio,
    \$Cd_Dotacao_Id,               \$Cd_Exerc_Empresa_Id,
    \$Administracao,               \$Cd_Orgao,
    \$Sigla_Orgao,                 \$Ds_Orgao,
    \$Cd_Unidade,                  \$Ds_Unidade,
    \$Cd_Funcao,                   \$Ds_Funcao,
    \$Cd_SubFuncao,                \$Ds_SubFuncao,
    \$Cd_Programa,                 \$Ds_Programa,
    \$Tp_Projeto_Atividade,        \$Cd_Projeto_Atividade,
    \$PA,                          \$PAPA,
    \$ProjetoAtividade,            \$Ds_Projeto_Atividade,
    \$Cd_Despesa,                  \$Ds_Despesa,
    \$Categoria_Despesa,           \$Ds_Categoria,
    \$Grupo_Despesa,               \$Ds_Grupo,
    \$Cd_Modalidade,               \$Ds_Modalidade,
    \$Cd_Elemento,                 \$Cd_Fonte,
    \$Ds_Fonte,                    \$Sld_Orcado_Ano,
    \$Vl_Correcao_Dotac,           \$Vl_Deflacao_Dotac,
    \$Vl_Suplementado,             \$Vl_Reduzido,
    \$Vl_SuplementadoLiquido,      \$Vl_Atualizado,
    \$Vl_SuplementadoEmTramitacao, \$Vl_ReduzidoEmTramitacao,
    \$Vl_Congelado,                \$Vl_Descongelado,
    \$Vl_CongeladoLiquido,         \$Vl_Reservado,
    \$Vl_Cancelado,                \$Vl_ReservadoLiquido,
    \$Vl_Empenhado,                \$Vl_Anulado,
    \$Vl_EmpenhadoLiquido,         \$Vl_Liquidado,
    \$Vl_Pago,                     \$Jan_Prev,
    \$Jan_Real,                    \$Jan_Pag,
    \$Fev_Prev,                    \$Fev_Real,
    \$Fev_Pag,                     \$Mar_Prev,
    \$Mar_Real,                    \$Mar_Pag,
    \$Abr_Prev,                    \$Abr_Real,
    \$Abr_Pag,                     \$Mai_Prev,
    \$Mai_Real,                    \$Mai_Pag,
    \$Jun_Prev,                    \$Jun_Real,
    \$Jun_Pag,                     \$Jul_Prev,
    \$Jul_Real,                    \$Jul_Pag,
    \$Ago_Prev,                    \$Ago_Real,
    \$Ago_Pag,                     \$Set_Prev,
    \$Set_Real,                    \$Set_Pag,
    \$Out_Prev,                    \$Out_Real,
    \$Out_Pag,                     \$Nov_Prev,
    \$Nov_Real,                    \$Nov_Pag,
    \$Dez_Prev,                    \$Dez_Real,
    \$Dez_Pag,                     \$DataExtracao
);

open my $fh, $ARGV[1] or die 'error';

my $line = 0;

while ( my $row = $csv->getline($fh) ) {
    $line++;
    next if $Cd_Funcao eq 'Cd_Funcao' or !$Vl_Liquidado;
    $Vl_Liquidado =~ s/\,//g;
    $Vl_Liquidado =~ s/\ //g;
    warn $line . "- $Vl_Liquidado";
    next if $Vl_Liquidado =~ '-';

            my $str = random_regex('\d\d\d\d\d\d\d\d\d\d\d\d');
    my $obj = $rs->create(
        {
            dataset_id => $dataset->id,

            funcao => $schema->resultset('Funcao')->find_or_create(
                { codigo => $Cd_Funcao, nome => $Ds_Funcao }
            ),

            subfuncao => $schema->resultset('Subfuncao')->find_or_create(
                { codigo => $Cd_SubFuncao, nome => $Ds_SubFuncao }
            ),

            programa => $schema->resultset('Programa')->find_or_create(
                {
                    codigo => $Cd_Programa,
                    nome   => &remover_acentos($Ds_Programa)
                }
            ),

            acao => $schema->resultset('Acao')->find_or_create(
                {
                    codigo => $Cd_Projeto_Atividade,
                    nome   => &remover_acentos($Ds_Projeto_Atividade)
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
                    codigo => $Cd_Despesa,
                    nome   => &remover_acentos($Ds_Despesa)
                }
            ),

            gestora => $schema->resultset('Gestora')->find_or_create(
                {
                    codigo => 'NAO-INFORMADO',
                    nome   => 'NAO-INFORMADO'
                }
            ),
            pagamento => $schema->resultset('Pagamento')->find_or_create(
                {
                    numero_processo => "NAO-INFORMADO-$Cd_Projeto_Atividade-$str",
                    numero_nota_empenho => 'NAO-INFORMADO',
                    tipo_licitacao  => 'NAO-INFORMADO',
                    valor_empenhado => $Vl_Liquidado,
                    valor_liquidado => $Vl_Liquidado,
                    valor_pago_anos_anteriores => $Vl_Liquidado
                }
            ),

            recurso => $schema->resultset('Recurso')->find_or_create(
                {
                    codigo => 'NAO-INFORMADO',
                    nome   => 'NAO-INFORMADO'
                }
            ),
            valor => $Vl_Liquidado
        }
    );

    print "funcao, $Ds_Funcao\n";
    print "subfuncao, $Ds_SubFuncao\n";
    print "programa, $Ds_Programa\n";
    print "acao, $Ds_Projeto_Atividade\n";
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

