
package POFOMD::Schema::Result::Periodo;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('periodo');
__PACKAGE__->add_columns(
    'id' => {
        'data_type'         => 'integer',
        'is_auto_increment' => 1,
        is_nullable         => 0,
        sequence            => "acao_id_seq",
    },
    'ano' => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(
    'datasets',
    'POFOMD::Schema::Result::Dataset',
    { "foreign.ano_id" => "self.id" },
    { cascade_copy     => 0, cascade_delete => 0 },
);

1;

