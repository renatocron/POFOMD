
package POFOMD::Schema::Result::Gasto;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('gasto');
__PACKAGE__->add_columns(
    'id' => {
        'data_type'         => 'integer',
        'is_auto_increment' => 1,
        is_nullable         => 0,
        sequence            => "gasto_id_seq",
    },
    'dataset_id'      => { 'data_type' => 'interger' },
    'funcao_id'       => { 'data_type' => 'integer' },
    'subfuncao_id'    => { 'data_type' => 'integer' },
    'programa_id'     => { 'data_type' => 'integer' },
    'acao_id'         => { 'data_type' => 'integer' },
    'beneficiario_id' => { 'data_type' => 'integer' },
    'despesa_id'      => { 'data_type' => 'interger' },
    'pagamento_id'    => { 'data_type' => 'integer' },
    'valor_pago'      => { 'data_type' => 'integer' }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
    dataset => 'POFOMD::Schema::Result::Dataset' =>
      { 'foreign.id' => 'self.dataset_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);
__PACKAGE__->belongs_to(
    funcao => 'POFOMD::Schema::Result::Funcao' =>
      { 'foreign.id' => 'self.funcao_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);
__PACKAGE__->belongs_to(
    subfuncao => 'POFOMD::Schema::Result::Subfuncao' =>
      { 'foreign.id' => 'self.subfuncao_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);
__PACKAGE__->belongs_to(
    programa => 'POFOMD::Schema::Result::Programa' =>
      { 'foreign.id' => 'self.programa_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);
__PACKAGE__->belongs_to(
    acao => 'POFOMD::Schema::Result::Acao' =>
      { 'foreign.id' => 'self.acao_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);
__PACKAGE__->belongs_to(
    beneficiario => 'POFOMD::Schema::Result::Beneficiario' =>
      { 'foreign.id' => 'self.beneficiario_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);
__PACKAGE__->belongs_to(
    despesa => 'POFOMD::Schema::Result::Despesa' =>
      { 'foreign.id' => 'self.despesas_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);
__PACKAGE__->belongs_to(
    pagamento => 'POFOMD::Schema::Result::Pagamento' =>
      { 'foreign.id' => 'self.pagamento_id' },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE"
    },
);

1;

