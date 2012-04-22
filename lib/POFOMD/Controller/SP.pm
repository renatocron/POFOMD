package POFOMD::Controller::SP;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

use POFOMD::Utils qw(formata_real formata_valor formata_float bgcolor);
use Redis;

sub base : Chained('/base') : PathPart('sp') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash->{redis} = Redis->new;
}

sub sum_redis_keys {
    my ($redis, $key) = @_;
    my @all   = $redis->keys($key);
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
    $c->stash->{node} = join('/', '', 'sp', $c->stash->{year}, 'data');
}

sub root : Chained('year') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
}

sub root_funcoes : Chained('year') PathPart('') Args(1) {
    my ( $self, $c, $funcao_id ) = @_;
    $c->stash->{node} = join('/', $c->stash->{node}, $funcao_id);
}

sub root_subfuncoes : Chained('year') PathPart('') Args(2) {
    my ( $self, $c, $funcao_id, $subfuncao_id ) = @_;
    $c->stash->{node} = join('/', $c->stash->{node}, $funcao_id,
        $subfuncao_id);
}

sub root_programas : Chained('year') PathPart('') Args(3) {
    my ( $self, $c, $funcao_id, $subfuncao_id, $programa_id ) = @_;
    $c->stash->{node} = join('/', $c->stash->{node}, $funcao_id,
        $subfuncao_id, $programa_id);
}

sub root_acoes : Chained('year') PathPart('') Args(4) {
    my ( $self, $c, $funcao_id, $subfuncao_id, $programa_id, $acao_id ) = @_;
    $c->stash->{node} = join('/', $c->stash->{node}, $funcao_id,
        $subfuncao_id, $programa_id, $acao_id);
}

sub credor : Chained('year') PathPart('') Args(5) {
    my ( $self, $c, $funcao_id, $subfuncao_id, $programa_id, $acao_id, $credor_id ) = @_;
    my $redis = $c->stash->{redis};
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
                funcao_url => join( '/', '', 'sp', '2011', $l_funcao_id ),

                subfuncao     => $redis->get("SUBFUNCAO_$l_subfuncao_id"),
                subfuncao_url => join( '/', '', 'sp', '2011', $l_funcao_id, $l_subfuncao_id ),

                programa     => $redis->get("PROGRAMA_$l_programa_id"),
                programa_url => join( '/', '', 'sp', '2011', $l_funcao_id, $l_subfuncao_id, $l_programa_id ),

                acao => $redis->get("ACAO_$l_acao_id"),
                acao_url =>
                    join( '/', '', 'sp', '2011', $l_funcao_id, $l_subfuncao_id, $l_programa_id, $l_acao_id ),

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
        if (!$total) {
            $total = &sum_redis_keys( $redis, "$id\_*" );
            $redis->set("CACHE_FUNCAO_SUM_$funcao", $total);
        }

        push( @data, { id => $id, display => $name, link => "/$id", total => $total } );
    }
    $c->stash->{data} = \@data;
    $c->forward('handle_TREE');
}

sub data_funcao : PathPart('data') : Chained('year') : Args(1) {
    my ( $self, $c, $target_funcao ) = @_;

    my $redis      = $c->stash->{redis};
    my @subfuncoes = $redis->keys("$target_funcao\_*");
    my @our_subfuncoes;
    my @data;

    foreach my $subfuncao (@subfuncoes) {
        my ( $funcao_id, $subfuncao_id, $programa_id ) = split( '_', $subfuncao );
        next if grep( /^$subfuncao_id$/, @our_subfuncoes );
        push( @our_subfuncoes, $subfuncao_id );
        my $name = $redis->get("SUBFUNCAO_$subfuncao_id");
        my $total = &sum_redis_keys( $redis, "$target_funcao\_$subfuncao_id\_*" );
        push(
            @data,
            {   id      => $subfuncao_id,
                display => $name,
                link    => "/$funcao_id/$subfuncao_id",
                total   => $total
            }
        );
    }

    $c->stash->{data} = \@data;
    $c->forward('handle_TREE');
}

sub data_subfuncao : PathPart('data') : Chained('year') : Args(2) {
    my ( $self, $c, $target_funcao, $target_subfuncao ) = @_;

    my $redis     = $c->stash->{redis};
    my @programas = $redis->keys("$target_funcao\_$target_subfuncao\_*");
    my @our_programas;
    my @data;

    foreach my $programa (@programas) {
        my ( $funcao_id, $subfuncao_id, $programa_id ) = split( '_', $programa );
        next if grep( /^$programa_id$/, @our_programas );
        push( @our_programas, $programa_id );
        my $name = $redis->get("PROGRAMA_$programa_id");
        my $total = &sum_redis_keys( $redis, "$target_funcao\_$subfuncao_id\_$programa_id\_*" );
        push(
            @data,
            {   id      => $programa_id,
                display => $name,
                link    => "/$funcao_id/$subfuncao_id/$programa_id",
                total   => $total
            }
        );
    }

    $c->stash->{data} = \@data;
    $c->forward('handle_TREE');
}

sub data_programas : PathPart('data') : Chained('year') : Args(3) {
    my ( $self, $c, $target_funcao, $target_subfuncao, $target_programa ) = @_;

    my $redis = $c->stash->{redis};
    my @acoes = $redis->keys("$target_funcao\_$target_subfuncao\_$target_programa\_*");
    my @our_acoes;
    my @data;

    foreach my $acao (@acoes) {
        my ( $funcao_id, $subfuncao_id, $programa_id, $acao_id ) = split( '_', $acao );
        next if grep( /^$acao_id$/, @our_acoes );
        push( @our_acoes, $acao_id );
        my $name = $redis->get("ACAO_$acao_id");
        my $total = &sum_redis_keys( $redis, "$target_funcao\_$subfuncao_id\_$programa_id\_$acao_id\_*" );
        push(
            @data,
            {   id      => $acao_id,
                display => $name,
                link    => "/$funcao_id/$subfuncao_id/$programa_id/$acao_id",
                total   => $total
            }
        );
    }

    $c->stash->{data} = \@data;
    $c->forward('handle_TREE');
}

sub data_acoes : PathPart('data') : Chained('year') : Args(4) {
    my ( $self, $c, $target_funcao, $target_subfuncao, $target_programa, $target_acao ) = @_;

    my $redis    = $c->stash->{redis};
    my @credores = $redis->keys("$target_funcao\_$target_subfuncao\_$target_programa\_$target_acao\_*");
    my @our_credores;
    my @data;

    foreach my $credor (@credores) {
        my ( $funcao_id, $subfuncao_id, $programa_id, $acao_id, $credor_id ) = split( '_', $credor );
        next if grep( /^$credor_id$/, @our_credores );
        push( @our_credores, $credor_id );
        my $name = $redis->get("CREDOR_$credor_id");
        my $total = &sum_redis_keys( $redis, "$target_funcao\_$subfuncao_id\_$programa_id\_$acao_id\_$credor_id" );
        push(
            @data,
            {   id      => $credor_id,
                display => $name,
                link    => "/$funcao_id/$subfuncao_id/$programa_id/$acao_id/$credor_id",
                total   => $total
            }
        );
    }

    $c->stash->{data} = \@data;
    $c->forward('handle_TREE');
}

sub handle_TREE : Private {
    my ( $self, $c ) = @_;

    my $total = 0;
    map { $total += $_->{total} } @{ $c->stash->{data} };
    $c->stash->{total_tree} = formata_real( $total, 2 );

    my @children;
    my @bgcolor         = bgcolor;
    my $bgcolor_default = '#c51d18';    # in config file ?

    foreach my $item ( @{ $c->stash->{data} } ) {
        next unless $item->{total};
        my $valor_porcentagem = $item->{total} * 100 / $total;
        my $color             = shift(@bgcolor) || $bgcolor_default;
        my $valor_print       = formata_valor( $item->{total} );
        my $porcentagem       = formata_float( $valor_porcentagem, 3 );
        my $zone              = '/';
        my $link              = '/sp/2011' . $item->{link};

        my $title = $item->{display};

        push(
            @children,
            {   data => {
                    title           => $title,
                    '$area'         => $porcentagem,
                    '$color'        => $color,
                    value           => $porcentagem,
                    printable_value => $valor_print,
                    porcentagem     => $porcentagem,
                    valor_tabela    => formata_real( $item->{total} ),
                    link            => $link,

                    ( $valor_porcentagem > 3 )
                    ? ( show_title => 'true' )
                    : (),

                },
                children => [],
                name     => $title,
                id       => $item->{id}
            }
        );
    }
    $c->stash->{children} = [@children];

    my @zones;
    my @zones_a;

    my @zones_a = ( { content => 'SP 2011', id => '/sp/2011' } );
    my @zones = ('SP 2011');
    $c->stash->{zones} = join( ', ', @zones ) if @zones;
    $c->stash->{zones_a} = [ reverse @zones_a ];

    delete $c->stash->{data};
    delete $c->stash->{redis};
    $c->forward('View::JSON');
}

__PACKAGE__->meta->make_immutable;

1;
