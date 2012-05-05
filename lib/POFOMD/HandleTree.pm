package POFOMD::HandleTree;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

use POFOMD::Utils qw(formata_real formata_valor formata_float bgcolor);

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
        my $link              = join('/', '', 'sp', $c->stash->{year},
            $item->{link});

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
    my $year = $c->stash->{year};

    my @zones_a = ( { content => "SP $year", id => "/sp/$year" } );
    my @zones = ("SP $year");
    $c->stash->{zones} = join( ', ', @zones ) if @zones;
    $c->stash->{zones_a} = [ reverse @zones_a ];

    delete $c->stash->{target_keys};
    delete $c->stash->{target_type};
    delete $c->stash->{target_name};
    delete $c->stash->{data};
    delete $c->stash->{redis};
    
    $c->forward('View::JSON');
}

1;
