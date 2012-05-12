package POFOMD::Controller::Eficiencia::SP::CamaraMunicipal;
use Moose;
use namespace::autoclean;

BEGIN { extends 'POFOMD::HandleTree' }

sub base : Chained('/base') : PathPart('eficiencia/sp/camaramunicipal') : CaptureArgs(1) {
    my ( $self, $c, $year ) = @_;
    $c->stash->{year} = $year;
}

sub root : Chained('base') PathPart('') : Args(0) {}

sub credores : Chained('base') : Args(0) {}

sub credor : Chained('base') : Args(1) {
    my ( $self, $c, $credor_id ) = @_;
}

__PACKAGE__->meta->make_immutable;

1;
