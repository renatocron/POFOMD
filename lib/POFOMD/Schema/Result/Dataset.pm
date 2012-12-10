
package POFOMD::Schema::Result::Dataset;

use strict;
use warnings;
use base 'DBIx::Class::Core';
use POFOMD::Utils qw(formata_valor);

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('dataset');
__PACKAGE__->add_columns(
    'id' => {
        'data_type'         => 'integer',
        'is_auto_increment' => 1,
        is_nullable         => 0,
        sequence            => "dataset_id_seq",
    },

    'nome'       => { 'data_type' => 'varchar' },
    'periodo_id' => { 'data_type' => 'integer' },
    'uri'        => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint( [qw/nome periodo_id/] );
__PACKAGE__->add_unique_constraint( [qw/uri/] );

__PACKAGE__->belongs_to(
    'periodo' => 'POFOMD::Schema::Result::Periodo' =>
      { 'foreign.id' => 'self.periodo_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);

__PACKAGE__->has_many(
    'gastos',
    'POFOMD::Schema::Result::Gasto',
    { "foreign.funcao_id" => "self.id" },
    { cascade_copy        => 0, cascade_delete => 0 },
);

1;

