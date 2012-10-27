
package POFOMD::Schema::Result::Programa;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('programa');
__PACKAGE__->add_columns(
    'programa_id' => { 'data_type' => 'integer', 'is_auto_increment' => 1 },
    'codigo'      => { 'data_type' => 'varchar' },
    'nome'        => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('programa_id');

1;

