package POFOMD::Controller::SP;
use Moose;
use namespace::autoclean;

BEGIN { extends 'POFOMD::HandleTree' }

use POFOMD::Utils qw(formata_real formata_valor formata_float bgcolor);
use Redis;

sub base : Chained('/base') : PathPart('sp') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash->{redis} = Redis->new;
}

sub sum_redis_keys {
    my ( $redis, $key ) = @_;
    my @all = $redis->keys($key);
    return 0 unless @all;
    my $all_total = 0;
    map { $all_total += $_ } $redis->mget(@all);
    return $all_total;
}

sub year : Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $year ) = @_;
    $c->stash->{year} = $year;
    $c->stash->{redis}->select("sp$year");
    $c->stash->{template} = 'node.tt';
    $c->stash->{node} = join( '/', '', 'sp', $c->stash->{year}, 'data' );
}

sub root : Chained('year') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
}

sub root_funcoes : Chained('year') PathPart('') Args(1) {
    my ( $self, $c, $funcao_id ) = @_;
    $c->stash->{node} = join( '/', $c->stash->{node}, $funcao_id );
}

sub root_subfuncoes : Chained('year') PathPart('') Args(2) {
    my ( $self, $c, $funcao_id, $subfuncao_id ) = @_;
    $c->stash->{node} = join( '/', $c->stash->{node}, $funcao_id, $subfuncao_id );
}

sub root_programas : Chained('year') PathPart('') Args(3) {
    my ( $self, $c, $funcao_id, $subfuncao_id, $programa_id ) = @_;
    $c->stash->{node} = join( '/', $c->stash->{node}, $funcao_id, $subfuncao_id, $programa_id );
}

sub root_acoes : Chained('year') PathPart('') Args(4) {
    my ( $self, $c, $funcao_id, $subfuncao_id, $programa_id, $acao_id ) = @_;
    $c->stash->{node} = join( '/', $c->stash->{node}, $funcao_id, $subfuncao_id, $programa_id, $acao_id );
}

sub credor_acoes : Chained('year') PathPart('') Args(5) {
    my ( $self, $c, $funcao_id, $subfuncao_id, $programa_id, $acao_id, $credor_id ) = @_;
    $c->res->redirect( join( '/', '', 'sp', $c->stash->{year}, 'credor', $credor_id ) );
}

sub credor : Chained('year') PathPart('credor') Args(1) {
    my ( $self, $c, $credor_id ) = @_;
    my $redis = $c->stash->{redis};
    my $year  = $c->stash->{year};
    $c->stash->{template} = 'credor.tt';

    $c->stash->{credor_nome} = $redis->get("CREDOR_$credor_id");

    my @ocorrencias = $redis->keys("*_*_*_*_$credor_id");
    my @links;

    my $total = 0;
    foreach my $ocorrencia (@ocorrencias) {
        my ( $l_funcao_id, $l_subfuncao_id, $l_programa_id, $l_acao_id, $l_credor_id ) = split( '_', $ocorrencia );
        my $ocorrencia_valor = $redis->get($ocorrencia);

        push(
            @links,
            {   funcao     => $redis->get("FUNCAO_$l_funcao_id"),
                funcao_url => join( '/', '', 'sp', $year, $l_funcao_id ),

                subfuncao     => $redis->get("SUBFUNCAO_$l_subfuncao_id"),
                subfuncao_url => join( '/', '', 'sp', $year, $l_funcao_id, $l_subfuncao_id ),

                programa     => $redis->get("PROGRAMA_$l_programa_id"),
                programa_url => join( '/', '', 'sp', $year, $l_funcao_id, $l_subfuncao_id, $l_programa_id ),

                acao => $redis->get("ACAO_$l_acao_id"),
                acao_url =>
                    join( '/', '', 'sp', $year, $l_funcao_id, $l_subfuncao_id, $l_programa_id, $l_acao_id ),

                valor => formata_real( $ocorrencia_valor, 2 ),

            }
        );

        $total += $ocorrencia_valor;
    }

    $c->stash->{total} = formata_real( $total, 2 );
    $c->stash->{links} = [@links];
}

sub data : Chained('year') Args(0) {
    my ( $self, $c ) = @_;
    my $redis   = $c->stash->{redis};
    my @funcoes = $redis->keys("FUNCAO_*");
    my @data;
    foreach my $funcao (@funcoes) {
        my ( $foo, $id ) = split( '_', $funcao );
        my $name = $redis->get($funcao);

        my $total = $redis->get("CACHE_FUNCAO_SUM_$funcao");
        if ( !$total ) {
            $total = &sum_redis_keys( $redis, "$id\_*" );
            $redis->set( "CACHE_FUNCAO_SUM_$funcao", $total );
        }

        push( @data, { id => $id, display => $name, link => "$id", total => $total } );
    }
    $c->stash->{data} = \@data;
    $c->forward('handle_TREE');
}

sub data_funcao : PathPart('data') : Chained('year') : Args(1) {
    my ( $self, $c, $target_funcao ) = @_;

    @{ $c->stash->{target_keys} } = $c->stash->{redis}->keys("$target_funcao\_*");
    $c->stash->{target_type} = 1;
    $c->stash->{target_name} = 'SUBFUNCAO';
    $c->forward('handle_DATA');
}

sub data_subfuncao : PathPart('data') : Chained('year') : Args(2) {
    my ( $self, $c, $target_funcao, $target_subfuncao ) = @_;

    @{ $c->stash->{target_keys} } = $c->stash->{redis}->keys("$target_funcao\_$target_subfuncao\_*");
    $c->stash->{target_type} = 2;
    $c->stash->{target_name} = 'PROGRAMA';
    $c->forward('handle_DATA');
}

sub data_programas : PathPart('data') : Chained('year') : Args(3) {
    my ( $self, $c, $target_funcao, $target_subfuncao, $target_programa ) = @_;

    @{ $c->stash->{target_keys} }
        = $c->stash->{redis}->keys("$target_funcao\_$target_subfuncao\_$target_programa\_*");
    $c->stash->{target_type} = 3;
    $c->stash->{target_name} = 'ACAO';
    $c->forward('handle_DATA');
}

sub data_acoes : PathPart('data') : Chained('year') : Args(4) {
    my ( $self, $c, $target_funcao, $target_subfuncao, $target_programa, $target_acao ) = @_;

    @{ $c->stash->{target_keys} }
        = $c->stash->{redis}->keys("$target_funcao\_$target_subfuncao\_$target_programa\_$target_acao\_*");
    $c->stash->{target_type} = 4;
    $c->stash->{target_name} = 'CREDOR';
    $c->forward('handle_DATA');
}

sub handle_DATA : Private {
    my ( $self, $c ) = @_;

    my $redis = $c->stash->{redis};
    my @our_target;
    my @data;
    my %sum_credores;
    my $total_all;

    # Verificando todas as chaves que estão no redis.
    foreach my $target ( @{ $c->stash->{target_keys} } ) {
        my @targets = split( '_', $target );

        # Preparando a ordem para buscar os maiores credores das chaves
        # em questão.
        if ( $c->stash->{target_type} != 4 ) {
            my $credor_id    = $targets[4];
            my $credor_value = $redis->get($target);

            $sum_credores{$credor_id}
                = exists( $sum_credores{$credor_id} ) ? $sum_credores{$credor_id} + $credor_value : $credor_value;
        }

        # Caso este tipo de chave (target_type) já foi processado, não
        # há necessidade de processar novamente.
        my $target_id = $targets[ $c->stash->{target_type} ];
        next if grep( /^$target_id$/, @our_target );
        push( @our_target, $target_id );

        # Buscando o nome do tipo da chave.
        my $name = $redis->get( join( '_', $c->stash->{target_name}, $target_id ) );

        # Calculando o total das chaves em questão.
        my $total;

        # last
        if ( @targets - 1 == $c->stash->{target_type} ) {
            $total = &sum_redis_keys( $redis, join( '_', @targets[ 0 .. $c->stash->{target_type} ] ) );
        }
        else {
            $total = &sum_redis_keys( $redis, join( '_', @targets[ 0 .. $c->stash->{target_type} ], '*' ) );
        }

        # Preparando dados para handle_TREE
        push(
            @data,
            {   id      => $target_id,
                display => $name,
                link    => join( '/', @targets[ 0 .. $c->stash->{target_type} ] ),
                total   => $total
            }
        );

        # Soma total para utilizar na porcentagem dos credores
        $total_all += $total;
    }

    my @all_credores;
    my @sort_credores = sort { $sum_credores{$b} <=> $sum_credores{$a} } keys %sum_credores;

    #foreach my $current_credor (keys %sum_credores) {
    foreach my $current_credor (@sort_credores) {
        my $credor_name       = $redis->get("CREDOR_$current_credor");
        my $credor_total      = $sum_credores{$current_credor};
        my $valor_porcentagem = $credor_total * 100 / $total_all;
        push(
            @all_credores,
            {   name  => $credor_name,
                id    => $current_credor,
                total => formata_valor($credor_total),
                link  => join( '/', '', 'sp', $c->stash->{year}, 'credor', $current_credor ),
                porcentagem => formata_float( $valor_porcentagem, 5 )
            }
        );
    }

    $c->stash->{credores} = \@all_credores if @all_credores;
    $c->stash->{data} = \@data;
    $c->forward('handle_TREE');
}

__PACKAGE__->meta->make_immutable;

1;
