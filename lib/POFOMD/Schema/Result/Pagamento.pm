
package POFOMD::Schema::Result::Pagamento;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('pagamento');
__PACKAGE__->add_columns(
    'pagamento_id'    => { 'data_type' => 'integer', 'is_auto_increment' => 1 },
    'tipo_licitacao'  => { 'data_type' => 'integer' },
    'valor_empenhado' => { 'data_type' => 'float' },
    'valor_liquidado' => { 'data_type' => 'float' },
    'valor_pago_anos_anteriores' => { 'data_type' => 'float' },
    'nome'                       => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('pagamento_id');

1;

