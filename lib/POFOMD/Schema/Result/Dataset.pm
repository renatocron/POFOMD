
package POFOMD::Schema::Result::Dataset;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('dataset');
__PACKAGE__->add_columns(
    'id' => {
        'data_type'         => 'integer',
        'is_auto_increment' => 1,
        is_nullable         => 0,
        sequence            => "dataset_id_seq",
    },

    'nome' => { 'data_type' => 'varchar' },
    'ano'  => { 'data_type' => 'integer' }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint( [qw/nome ano/] );

__PACKAGE__->has_many(
    'gastos',
    'POFOMD::Schema::Result::Gasto',
    { "foreign.funcao_id" => "self.id" },
    { cascade_copy        => 0, cascade_delete => 0 },
);

1;
