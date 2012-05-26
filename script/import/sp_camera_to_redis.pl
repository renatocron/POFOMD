#!/usr/bin/env perl
#
# Aware TI, 2012, http://www.aware.com.br
# Thiago Rondon <thiago@aware.com.br>
#

use strict;
use warnings;

use XML::Simple;
use Data::Dumper;
use Redis;

# Orçado
my $year  = $ARGV[0];
my $ref   = XMLin("CMSP-dot$year.xml");
my $redis = Redis->new;

foreach my $modalidade ( @{ $ref->{G_Categoria} } ) {

    #    print $modalidade->{Categoria_Descricao} . "\n";
    #    print "Categoria: " . $modalidade->{Categoria} . "\n";
    my $dotacao = $modalidade->{Fichas}->{Dotacao};

    my $modalidade_total = 0;
    if ( ref($dotacao) eq 'HASH' ) {
        $modalidade_total = $modalidade->{Fichas}->{Dotacao}->{Orcado};
    }
    else {
        map { $modalidade_total += $_->{Orcado} } @${dotacao};
    }

    #    print "Valor: $modalidade_total \n";

    #    print "\n";
    my $key = join( '-', 'CMSP', 'MODALIDADE', 'PLANEJADO', $year, $modalidade->{Categoria} );

    print "$key = $modalidade_total\n";
    $redis->set($key, $modalidade_total);

    $key = join( '-', 'NAME', $key );
    my $name = $modalidade->{Categoria_Descricao};
    print "$key = $name\n";
    $redis->set($key, $name);
    #    print "-" x 80 . "\n";
}

# Executado
my $ref = XMLin('CMSP-pag2010-2012.xml');

my %chaves;
foreach my $pagamento (@{$ref->{Instituicao}}) {
    next unless $pagamento->{AnoReferencia}; 

    my $ano = $pagamento->{AnoReferencia};
    my $categoria = $pagamento->{categoriaQuebra};
    my $codpessoa = $pagamento->{codPessoa};
    my $valorpago = $pagamento->{ValorPago};
    my $licitacao = $pagamento->{Licitacao};
    my $FORNECEDOR = $pagamento->{FORNECEDOR};
    $valorpago =~ s/\,/\./g;

    my $key = "$ano-$categoria-$codpessoa";
    my $key_cat = "$ano-$categoria";

    $chaves{$key_cat} = 0 unless $chaves{$key_cat};
    $chaves{$key_cat} += $valorpago;


}

foreach my $chave (keys %chaves) {
    next unless $chave =~ /$year/;
    my $key_executado = join('-', 'CMSP', 'MODALIDADE', 'EXECUTADO', $chave);
    print "$key_executado = " . $chaves{$chave} . "\n";
    $redis->set($key_executado, $chaves{$chave});
}






