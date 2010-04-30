package # hide from PAUSE
    DigestTest::Schema;

use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_classes(qw/Test TableA TableB/);

1;
