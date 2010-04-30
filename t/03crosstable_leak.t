#! /usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 5;

use Dir::Self;
use File::Spec;
use File::Temp 'tempdir';

use lib File::Spec->catdir(__DIR__, 'lib');

#1
BEGIN { use_ok("DigestTest::Schema"); }

# ABOUT THIS TEST;
#
# TableA is not encoded.
# TableB is encoded.
#
# Both share a field with the same name.
#
# This test is to demonstrate, that one is inheriting the encoding options wrongly from the other.
#

my $tmp = tempdir( CLEANUP => 1 );
my $db_file = File::Spec->catfile($tmp, 'testdb.sqlite');
my $schema = DigestTest::Schema->connect("dbi:SQLite:dbname=${db_file}");
$schema->deploy({}, File::Spec->catdir(__DIR__, 'var'));

my $tablea = $schema->resultset('TableA');
my $tableb = $schema->resultset('TableB');

my $objecta = $tablea->create( { conflicting_name => 'foo' } );
my $objectb = $tableb->create( { conflicting_name => 'bar' } );

is( $objecta->conflicting_name, 'foo', 'Table requested to not be encoded is not encoded' );
unlike( $objectb->conflicting_name, qr/^(bar|foo)$/, 'Table requested to be encoded is encoded' );

is( $objecta->can('check_conflict'), undef, 'Table that is requested to not be encoded has no check_conflict method' );
ok( $objectb->can('check_conflict'), 'Table that is requested encoded has check_conflict method' );

1;
