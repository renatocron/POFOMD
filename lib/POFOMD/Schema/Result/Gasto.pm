
package POFOMD::Schema::Result::Gasto;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('gasto');
__PACKAGE__->add_columns(
    'gasto_id'     => { 'data_type' => 'integer', 'is_auto_increment' => 1 },
    'dataset_id'   => { 'data_type' => 'interger' },
    'funcao_id'    => { 'data_type' => 'integer' },
    'subfuncao_id' => { 'data_type' => 'integer' },
    'programa_id'  => { 'data_type' => 'integer' },
    'acao_id'      => { 'data_type' => 'integer' },
    'beneficiario_id' => { 'data_type' => 'integer' },
    'despesa_id'      => { 'data_type' => 'interger' },
    'pagamento_id'    => { 'data_type' => 'integer' },
    'valor_pago'      => { 'data_type' => 'integer' }
);

__PACKAGE__->set_primary_key('gasto_id');

__PACKAGE__->belongs_to(
    dataset_id => 'POFOMD::Schema::Result::Dataset' => 'dataset_id' );
__PACKAGE__->belongs_to(
    funcao_id => 'POFOMD::Schema::Result::Funcao' => 'funcao_id' );
__PACKAGE__->belongs_to(
    subfuncao_id => 'POFOMD::Schema::Result::Subfuncao' => 'subfuncao_id' );
__PACKAGE__->belongs_to(
    programa_id => 'POFOMD::Schema::Result::Programa' => 'programa_id' );
__PACKAGE__->belongs_to(
    acao_id => 'POFOMD::Schema::Result::Acao' => 'acao_id' );
__PACKAGE__->belongs_to(
    beneficiario_id => 'POFOMD::Schema::Result::Beneficiario' =>
      'beneficiario_id' );
__PACKAGE__->belongs_to(
    despesa_id => 'POFOMD::Schema::Result::Despesa' => 'despesa_id' );
__PACKAGE__->belongs_to(
    pagamento_id => 'POFOMD::Schema::Result::Pagamento' => 'pagamento_id' );

1;

