package DBIx::Class::EncodedColumn::Digest;

use strict;
use warnings;

our $VERSION = '0.00001_01';

sub make_encode_sub {
  my($class, $args) = @_;
  my $for = exists $args->{format}    ? $args->{format}    : 'base64';
  my $alg = exists $args->{algorithm} ? $args->{algorithm} : 'SHA-256';

 die("Valid Digest formats are 'binary', 'hex' or 'base64'. You used '$for'.")
   unless $for =~ /^(?:hex|base64|binary)$/;
  defined(my $object = eval{ Digest->new($alg) }) ||
    die("Can't use Digest algorithm ${alg}: $@");

  my $format_method = $for eq 'binary' ? 'digest' :
    ($for eq 'hex' ? 'hexdigest' : 'b64digest');

  my $encoder = sub {
    $object->add(@_);
    return $object->$format_method;
  };

  return $encoder;
}

sub make_check_sub {
  my($class, $col) = @_;
  my $current = '$_[0]->get_column("'.$col.'")';
  my $check   = '$_[0]->_column_encoders->{"'.$col.'"}->($_[1])';
  eval "sub { $current eq $check }";
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

=head2 make_encode_sub \%args

Returns a coderef that accepts a plaintext value and returns an encoded value

=head2 make_check_sub $column_name

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
