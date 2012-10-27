
package POFOMD::Schema::Result::Beneficiario;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('beneficiario');
__PACKAGE__->add_columns(
    'beneficiario_id' => { 'data_type' => 'integer', 'is_auto_increment' => 1 },
    'codigo'    => { 'data_type' => 'varchar' },
    'nome'      => { 'data_type' => 'varchar' },
    'documento' => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('beneficiario_id');

__PACKAGE__->add_unique_constraint( [ qw/codigo/ ] );

__PACKAGE__->has_many( gastos => "POFOMD::Schema::Result::Gasto", 'beneficiario_id' );

1;

