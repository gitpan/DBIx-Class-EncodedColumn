#! /usr/bin/perl -w

use strict;
use warnings;
use Test::More;
use Digest;

use File::Spec;
use FindBin '$Bin';
use lib File::Spec->catdir($Bin, 'lib');

my ($sha_ok, $bcrypt_ok);
BEGIN {
  $sha_ok    = eval 'require Digest' && eval 'require Digest::SHA;';
  $bcrypt_ok = eval 'require Crypt::Eksblowfish::Bcrypt';
}

my $tests = 5;
$tests += 21 if $sha_ok;
$tests += 6  if $bcrypt_ok;

plan tests => $tests;

use_ok("DigestTest");

my $schema = DigestTest->init_schema;
my $rs     = $schema->resultset('Test');

my $checks = {};
if( $sha_ok ){
  for my $algorithm( qw/SHA-1 SHA-256/){
    my $maker = Digest->new($algorithm);
    my $encodings = $checks->{$algorithm} = {};
    for my $encoding (qw/base64 hex/){
      my $values = $encodings->{$encoding} = {};
      my $encoding_method = $encoding eq 'binary' ? 'digest' :
        ($encoding eq 'hex' ? 'hexdigest' : 'b64digest');
      for my $value (qw/test1 test2/){
        $maker->add($value);
        $values->{$value} = $maker->$encoding_method;
      }
    }
  }
}

my %create_vals = (dummy_col  => 'test1');
if( $sha_ok ){
  $create_vals{$_} = 'test1'
    for(qw/sha1_hex sha1_b64 sha256_hex sha256_b64 sha256_b64_salted/);
}

if( $bcrypt_ok ){
  $create_vals{$_} = 'test1' for(qw/bcrypt_1 bcrypt_2/);
}

my $row = $rs->create( \%create_vals );

is($row->dummy_col,  'test1',                            'dummy on create');
ok(!$row->can('check_dummy_col'));

if( $bcrypt_ok ){
  is( length($row->bcrypt_1), 60, 'correct length');
  is( length($row->bcrypt_2), 59, 'correct length');

  ok( $row->bcrypt_1_check('test1'));
  ok( $row->bcrypt_2_check('test1'));

  $row->bcrypt_1('test2');
  $row->bcrypt_2('test2');

  ok( $row->bcrypt_1_check('test2'));
  ok( $row->bcrypt_2_check('test2'));
}

if( $sha_ok ) {
  is($row->sha1_hex,   $checks->{'SHA-1'}{hex}{test1},     'hex sha1 on create');
  is($row->sha1_b64,   $checks->{'SHA-1'}{base64}{test1},  'b64 sha1 on create');
  is($row->sha256_hex, $checks->{'SHA-256'}{hex}{test1},   'hex sha256 on create');
  is($row->sha256b64,  $checks->{'SHA-256'}{base64}{test1},'b64 sha256 on create');
  is( length($row->sha256_b64_salted), 57, 'correct salted length');

#   my $salted_check = sub {
#     my $col_v = $_[0]->get_column('sha256_b64_salted');
#     my $target = substr($col_v, 0, 43);
#     my $salt   = substr($col_v, 43);
#     my $maybe = $_[0]->_column_encoders->{'sha256_b64_salted'}->($_[1], $salt);
#     print STDERR "$_[1]\t${salt}\t${maybe}\n";
#     $maybe eq $col_v;
#  };

  #die unless $salted_check->($row, 'test1');

  can_ok($row, qw/check_sha1_hex check_sha1_b64/);
  ok($row->check_sha1_hex('test1'),'Checking hex digest_check_method');
  ok($row->check_sha1_b64('test1'),'Checking b64 digest_check_method');
  ok($row->check_sha256_b64_salted('test1'), 'Checking salted digest_check_method');

  $row->sha1_hex('test2');
  is($row->sha1_hex, $checks->{'SHA-1'}{hex}{test2}, 'Checking accessor');

  $row->update({sha1_b64 => 'test2',  dummy_col => 'test2'});
  is($row->sha1_b64, $checks->{'SHA-1'}{base64}{test2}, 'Checking update');
  is($row->dummy_col,  'test2', 'dummy on update');

  $row->set_column(sha256_hex => 'test2');
  is($row->sha256_hex, $checks->{'SHA-256'}{hex}{test2}, 'Checking set_column');

  $row->sha256b64('test2');
  is($row->sha256b64, $checks->{'SHA-256'}{base64}{test2}, 'custom accessor');

  $row->update;

} else {

  $row->update({dummy_col => 'test2'});
  is($row->dummy_col,  'test2', 'dummy on update');

}

if( $sha_ok ) {
  my $copy = $row->copy({sha256_b64 => 'test2'});
  is($copy->sha1_hex,   $checks->{'SHA-1'}{hex}{test2},     'hex sha1 on copy');
  is($copy->sha1_b64,   $checks->{'SHA-1'}{base64}{test2},  'b64 sha1 on copy');
  is($copy->sha256_hex, $checks->{'SHA-256'}{hex}{test2},   'hex sha256 on copy');
  is($copy->sha256b64,  $checks->{'SHA-256'}{base64}{test2},'b64 sha256 on copy');
}

my $new = $rs->new( \%create_vals );
is($new->dummy_col,  'test1', 'dummy on new');

if( $sha_ok ){
  is($new->sha1_hex,   $checks->{'SHA-1'}{hex}{test1},      'hex sha1 on new');
  is($new->sha1_b64,   $checks->{'SHA-1'}{base64}{test1},   'b64 sha1 on new');
  is($new->sha256_hex, $checks->{'SHA-256'}{hex}{test1},    'hex sha256 on new');
  is($new->sha256b64,  $checks->{'SHA-256'}{base64}{test1}, 'b64 sha256 on new');
}

DigestTest->clear;

#TODO
# -- dies_ok tests when using invalid cyphers and encodings

1;

