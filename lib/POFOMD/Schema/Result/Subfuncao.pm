
package POFOMD::Schema::Result::Subfuncao;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('subfuncao');
__PACKAGE__->add_columns(
    'subfuncao_id' => { 'data_type' => 'integer', 'is_auto_increment' => 1 },
    'codigo'       => { 'data_type' => 'varchar' },
    'nome'         => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('subfuncao_id');

1;

