use utf8;

package POFOMD::Schema::Result::Node;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("node");

__PACKAGE__->add_columns(
    "id",
    {   data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "node_id_seq",
    },
    "dataset",
    { data_type => "integer", is_nullable => 0 },
    "ano",
    { data_type => "integer", is_nullable => 0 },
    "codigo_orgao",
    { data_type => "integer", is_nullable => 0 },
    "codigo_unidade_gestora",
    { data_type => "integer", is_nullable => 0 },
    "codigo_categoria_despesa",
    { data_type => "integer", is_nullable => 0 },
    "codigo_grupo_despesa",
    { data_type => "integer", is_nullable => 0 },
    "codigo_modalidade",
    { data_type => "integer", is_nullable => 0 },
    "codigo_elemento_despesa",
    { data_type => "integer", is_nullable => 0 },
    "codigo_item_despesa",
    { data_type => "integer", is_nullable => 0 },
    "codigo_funcao",
    { data_type => "integer", is_nullable => 0 },
    "codigo_subfuncao",
    { data_type => "integer", is_nullable => 0 },
    "codigo_programa",
    { data_type => "integer", is_nullable => 0 },
    "codigo_programa_de_trabalho",
    { data_type => "integer", is_nullable => 0 },
    "codigo_fonte_de_recursos",
    { data_type => "integer", is_nullable => 0 },
    "codigo_acao",
    { data_type => "integer", is_nullable => 0 },
    "codigo_credor",
    { data_type => "integer", is_nullable => 0 },
    "valor_empenhado",
    { data_type => "float", is_nullable => 0 },
    "valor_liquidado",
    { data_type => "integer", is_nullable => 0 },
    "valor_pago",
    { data_type => "integer", is_nullable => 0 },

);

__PACKAGE__->set_primary_key("id");

1;
