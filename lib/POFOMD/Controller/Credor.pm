package POFOMD::Controller::Credor;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

use POFOMD::Utils qw(formata_real formata_valor formata_float bgcolor);

sub base : Chained('/base') : PathPart('credor') : CaptureArgs(1) {
    my ( $self, $c, $uri ) = @_;
    my $ds = $c->model('DB::Beneficiario');
    my $ds_obj = $ds->find({ uri => $uri });
    $c->detach if !$ds_obj;
    $c->stash->{credor} = $ds_obj;
}

sub root : Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
}

__PACKAGE__->meta->make_immutable;

1;
