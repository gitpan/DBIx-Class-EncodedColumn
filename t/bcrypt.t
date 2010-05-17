
use strict;
use warnings;
use Test::More;

use Dir::Self;
use File::Spec;
use File::Temp 'tempdir';
use lib File::Spec->catdir(__DIR__, 'lib');

BEGIN {
  if( eval 'require Crypt::Eksblowfish::Bcrypt' ){
    plan tests => 7;
    use_ok('DigestTest::Schema');
  } else {
    plan skip_all => 'Crypt::Eksblowfish::Bcrypt not available';
    exit;
  }
}

#1
DigestTest::Schema->load_classes('Bcrypt');

my $tmp = tempdir( CLEANUP => 1 );
my $db_file = File::Spec->catfile($tmp, 'testdb.sqlite');
my $schema = DigestTest::Schema->connect("dbi:SQLite:dbname=${db_file}");
$schema->deploy({}, File::Spec->catdir(__DIR__, 'var'));

my %create_values = (bcrypt_1 => 'test1', bcrypt_2 => 'test1');
my $row = $schema->resultset('Bcrypt')->create( \%create_values );
is( length($row->bcrypt_1), 60, 'correct length');
is( length($row->bcrypt_2), 59, 'correct length');

ok( $row->bcrypt_1_check('test1'));
ok( $row->bcrypt_2_check('test1'));

$row->bcrypt_1('test2');
$row->bcrypt_2('test2');

ok( $row->bcrypt_1_check('test2'));
ok( $row->bcrypt_2_check('test2'));
