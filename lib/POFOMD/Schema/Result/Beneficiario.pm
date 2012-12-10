
package POFOMD::Schema::Result::Beneficiario;

use strict;
use warnings;
use base 'DBIx::Class::Core';
use POFOMD::Utils qw(formata_valor);

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('beneficiario');
__PACKAGE__->add_columns(
    'id' => {
        'data_type'         => 'integer',
        'is_auto_increment' => 1,
        is_nullable         => 0,
        sequence            => "beneficiario_id_seq",
    },
    'codigo'    => { 'data_type' => 'varchar' },
    'nome'      => { 'data_type' => 'varchar' },
    'documento' => { 'data_type' => 'varchar' },
    'uri'       => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint( [qw/codigo/] );
__PACKAGE__->add_unique_constraint( [qw/uri/] );

__PACKAGE__->has_many(
    'gastos',
    'POFOMD::Schema::Result::Gasto',
    { "foreign.beneficiario_id" => "self.id" },
    { cascade_copy              => 0, cascade_delete => 0 },
);

sub total {
    my $self  = shift;
    my $total = 0;
    map { $total += $_->valor } $self->gastos;
    return formata_valor($total);
}

1;

