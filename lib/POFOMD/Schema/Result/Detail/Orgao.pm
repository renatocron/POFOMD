use utf8;

package POFOMD::Schema::Result::Detail::Orgao;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("detail_orgao");

__PACKAGE__->add_columns(
    "id",
    {   data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "node_id_seq",
    },
    "nome",
    { data_type => "integer", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("id");

1;
