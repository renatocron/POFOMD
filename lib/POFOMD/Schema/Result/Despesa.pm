
package POFOMD::Schema::Result::Despesa;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('despesa');
__PACKAGE__->add_columns(
    'despesa_id' => { 'data_type' => 'integer', 'is_auto_increment' => 1 },
    'nome'      => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('despesa_id');

1;

