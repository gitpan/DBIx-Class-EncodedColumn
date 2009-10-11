#! /usr/bin/perl -w

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'DBIx-Class-EncodedColumn';
abstract "Automatically encode column values";
all_from 'lib/DBIx/Class/EncodedColumn.pm';

repository 'http://dev.catalyst.perl.org/repos/bast/trunk/DBIx-Class-EncodedColumn';

# Specific dependencies
requires 'DBIx::Class' => '0.06002';
requires 'Sub::Name' => '0.04';

#build dependencies
build_requires 'Test::More';
build_requires 'DBD::SQLite';
build_requires 'SQL::Translator' => '0.08000';
build_requires 'Digest::SHA';
build_requires 'File::Spec';

#recommended modules
feature 'Digest::MD5 Support?',
    -default => 1,
    'Digest',
    'Digest::MD5';

feature 'Digest::SHA Support?',
    -default => 1,
    'Digest',
    'Digest::SHA';

feature 'Blowfish Support?',
    -default => 1,
    'Crypt::Eksblowfish::Bcrypt';

feature  'Crypt::OpenPGP (gpg) Support?',
    -default => 1,
    'Crypt::OpenPGP',
    'Crypt::CAST5_PP';

WriteAll;
