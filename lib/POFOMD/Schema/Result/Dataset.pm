
package POFOMD::Schema::Result::Dataset;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('dataset');
__PACKAGE__->add_columns(
    'dataset_id' => { 'data_type' => 'integer', 'is_auto_increment' => 1 },
    'nome'       => { 'data_type' => 'varchar' },
    'ano'        => { 'data_type' => 'integer' }
);

__PACKAGE__->set_primary_key('dataset_id');

__PACKAGE__->has_many( gastos => 'POFOMD::Schema::Result::Gasto', 'dataset_id' );

1;

