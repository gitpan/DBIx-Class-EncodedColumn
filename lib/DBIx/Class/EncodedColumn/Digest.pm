package DBIx::Class::EncodedColumn::Digest;

use strict;
use warnings;
use Digest;

our $VERSION = '0.00001_02';

my %digest_lengths =
  (
   'MD2'       => { base64 => 22, binary => 16, hex => 32  },
   'MD4'       => { base64 => 22, binary => 16, hex => 32  },
   'MD5'       => { base64 => 22, binary => 16, hex => 32  },

   'SHA-1'     => { base64 => 27, binary => 20, hex => 40  },
   'SHA-256'   => { base64 => 43, binary => 32, hex => 64  },
   'SHA-384'   => { base64 => 64, binary => 48, hex => 96  },
   'SHA-512'   => { base64 => 86, binary => 64, hex => 128 },

   'CRC-CCITT' => { base64 => 2,  binary => 3,  hex => 3   },
   'CRC-16'    => { base64 => 6,  binary => 5,  hex => 4   },
   'CRC-32'    => { base64 => 14, binary => 10, hex => 8   },

   'Adler-32'  => { base64 => 6,  binary => 4,  hex => 8   },
   'Whirlpool' => { base64 => 86, binary => 64, hex => 128 },
   'Haval-256' => { base64 => 44, binary => 32, hex => 64  },
  );
my @salt_pool = ('A' .. 'Z', 'a' .. 'z', 0 .. 9, '+','/','=');

sub make_encode_sub {
  my($class, $col, $args) = @_;
  my $for  = $args->{format}      ||= 'base64';
  my $alg  = $args->{algorithm}   ||= 'SHA-256';
  my $slen = $args->{salt_length} ||= 0;

 die("Valid Digest formats are 'binary', 'hex' or 'base64'. You used '$for'.")
   unless $for =~ /^(?:hex|base64|binary)$/;
  defined(my $object = eval{ Digest->new($alg) }) ||
    die("Can't use Digest algorithm ${alg}: $@");

  my $format_method = $for eq 'binary' ? 'digest' :
    ($for eq 'hex' ? 'hexdigest' : 'b64digest');
  #thanks Haval for breaking the standard. thanks!
  $format_method = 'base64digest 'if ($alg eq 'Haval-256' && $for eq 'base64');

  my $encoder = sub {
    my ($plain_text, $salt) = @_;
    $salt ||= join('', map { $salt_pool[int(rand(65))] } 1 .. $slen);
    $object->add($plain_text.$salt);
    my $digest = $object->$format_method;
    #print "${plain_text}\t ${salt}:\t${digest}${salt}\n" if $salt;
    return $digest.$salt;
  };

  #in case i didn't prepopulate it
  $digest_lengths{$alg}{$for} ||= length($encoder->('test1'));
  return $encoder;
}

sub make_check_sub {
  my($class, $col, $args) = @_;

  #this is the digest length
  my $len = $digest_lengths{$args->{algorithm}}{$args->{format}};
  die("Unable to find digest length") unless defined $len;

  #fast fast fast
  return eval qq^ sub {
    my \$col_v = \$_[0]->get_column('${col}');
    my \$salt   = substr(\$col_v, ${len});
    \$_[0]->_column_encoders->{${col}}->(\$_[1], \$salt) eq \$col_v;
  } ^ || die($@);
}

1;

__END__;

=head1 NAME

DBIx::Class::EncodedColumn::Digest

=head1 SYNOPSYS

  #SHA-1 / hex encoding / generate check method
  __PACKAGE__->add_columns(
    'password' => {
      data_type   => 'CHAR',
      size        => 40,
      encode_column => 1,
      encode_class  => 'Digest',
      encode_args   => {algorithm => 'SHA-1', format => 'hex'},
      encode_check_method => 'check_password',
  }

  #SHA-256 / base64 encoding / generate check method
  __PACKAGE__->add_columns(
    'password' => {
      data_type   => 'CHAR',
      size        => 40,
      encode_column => 1,
      encode_class  => 'Digest',
      encode_check_method => 'check_password',
      #no  encode_args necessary because these are the defaults ...
  }


=head1 DESCRIPTION

=head1 ACCEPTED ARGUMENTS

=head2 digest_encoding

The encoding to use for the digest. Valid values are 'binary', 'hex', and
'base64'. Will default to 'base64' if not specified.

=head2 digest_algorithm

The digest algorithm to use for the digest. You may specify any valid L<Digest>
algorithm. Examples are L<MD5|Digest::MD5>, L<SHA-1|Digest::SHA>,
L<Whirlpool|Digest::Whirlpool> etc. Will default to 'SHA-256' if not specified.

See L<Digest> for supported digest algorithms.

=head1 METHODS

=head2 make_encode_sub $column_name, \%encode_args

Returns a coderef that accepts a plaintext value and returns an encoded value

=head2 make_check_sub $column_name, \%encode_args

Returns a coderef that when given the row object and a plaintext value will
return a boolean if the plaintext matches the encoded value. This is typically
used for password authentication.

=head1 SEE ALSO

L<DBIx::Class::EncodedColumn::Crypt::Eksblowfish::Bcrypt>,
L<DBIx::Class::EncodedColumn>, L<Digest>

=head1 AUTHOR

Guillermo Roditi (groditi) <groditi@cpan.org>

Based on the Vienna WoC  ToDo manager code by Matt S trout (mst)

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
