package # hide from PAUSE
    DigestTest::Schema::TableB;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/EncodedColumn Core/);
__PACKAGE__->table('tableb');
__PACKAGE__->add_columns(
  id => {
    data_type => 'int',
    is_nullable => 0,
    is_auto_increment => 1
  },
  conflicting_name => {
    data_type => 'char',
    size      => 43,
    encode_column => 1,
    encode_class  => 'Digest',
    encode_check_method => 'check_conflict',
  },
);

__PACKAGE__->set_primary_key('id');

1;
