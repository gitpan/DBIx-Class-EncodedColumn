package # hide from PAUSE
    DigestTest::Schema::Test;

my ($sha_ok, $bcrypt_ok);
BEGIN {
  $sha_ok    = eval 'require Digest' && eval 'require Digest::SHA;';
  $bcrypt_ok = eval 'require Crypt::Eksblowfish::Bcrypt';
  $pgp_ok    = eval 'require Crypt::OpenPGP';
}

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/EncodedColumn Core/);
__PACKAGE__->table('test');
__PACKAGE__->add_columns
  (
   id        => {
                 data_type => 'int',
                 is_nullable => 0,
                 is_auto_increment => 1
                },
   dummy_col => {
                 data_type => 'char',
                 size      => 43,
                 encode_column => 0,
                 encode_class  => 'Digest',
                 encode_check_method => 'check_dummy_col',
                },
  );

if( $sha_ok ) {
  __PACKAGE__->add_columns
    (
     sha1_hex => {
                  data_type => 'char',
                  is_nullable => 1,
                  size      => 40,
                  encode_column => 1,
                  encode_class  => 'Digest',
                  encode_args => {
                                  format    => 'hex',
                                  algorithm => 'SHA-1',
                                 },
                  encode_check_method => 'check_sha1_hex',
                 },
     sha1_b64 => {
                  data_type => 'char',
                  is_nullable => 1,
                  size      => 27,
                  encode_column => 1,
                  encode_class  => 'Digest',
                  encode_args => {
                                  algorithm => 'SHA-1',
                                 },
                  encode_check_method => 'check_sha1_b64',
               },
     sha256_hex => {
                    data_type => 'char',
                    is_nullable => 1,
                    size      => 64,
                    encode_column => 1,
                    encode_class  => 'Digest',
                    encode_args => { format => 'hex',},
                   },
     sha256_b64 => {
                    data_type => 'char',
                    is_nullable => 1,
                    size      => 43,
                    accessor  => 'sha256b64',
                    encode_column => 1,
                    encode_class  => 'Digest',
                   },
     sha256_b64_salted => {
                           data_type => 'char',
                           is_nullable => 1,
                           size      => 57,
                           encode_column => 1,
                           encode_class  => 'Digest',
                           encode_check_method => 'check_sha256_b64_salted',
                           encode_args   => {salt_length => 14}
                         },
    );
}

if( $bcrypt_ok ){
  __PACKAGE__->add_columns
    (
     bcrypt_1 => {
                  data_type => 'text',
                  is_nullable => 1,
                  size => 60,
                  encode_column => 1,
                  encode_class  => 'Crypt::Eksblowfish::Bcrypt',
                  encode_check_method => 'bcrypt_1_check',
                 },
     bcrypt_2 => {
                  data_type => 'text',
                  is_nullable => 1,
                  size => 59,
                  encode_column => 1,
                  encode_class  => 'Crypt::Eksblowfish::Bcrypt',
                  encode_args   => {key_nul => 0, cost => 6 },
                  encode_check_method => 'bcrypt_2_check',
                 },
     );
}

if( $pgp_ok ){
    my $pgp_conf = {
        SecRing => "$FindBin::Bin/secring.gpg",
        PubRing => "$FindBin::Bin/pubring.gpg",
    };
    __PACKAGE__->add_columns(
        pgp_col_passphrase => {
            data_type => 'text',
            is_nullable => 1,
            encode_column => 1,
            encode_class  => 'Crypt::OpenPGP',
            encode_args => {
                passphrase => 'Secret Words',
                armour     => 1
            },
            encode_check_method => 'decrypt_pgp_passphrase',
        },
        pgp_col_key => {
            data_type => 'text',
            is_nullable => 1,
            encode_column => 1,
            encode_class  => 'Crypt::OpenPGP',
            encode_args => {
                recipient => '1B8924AA',
                pgp_args   => $pgp_conf,
                armour     => 1
            },
            encode_check_method => 'decrypt_pgp_key',
        },
        pgp_col_key_ps => {
            data_type => 'text',
            is_nullable => 1,
            encode_column => 1,
            encode_class  => 'Crypt::OpenPGP',
            encode_args => {
                recipient => '7BEF6294',
                pgp_args   => $pgp_conf,
                armour     => 1
            },
            encode_check_method => 'decrypt_pgp_key_ps',
        },
    );
}

__PACKAGE__->set_primary_key('id');

1;
