#! /usr/bin/perl -w

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'DBIx-Class-EncodedColumn';
abstract "Automatically encode column values";
all_from 'lib/DBIx/Class/EncodedColumn.pm';

# Specific dependencies
requires 'DBIx::Class' => '0.06002';

#build dependencies
build_requires 'Test::More';
build_requires 'DBD::SQLite';
build_requires 'SQL::Translator' => '0.08000';
build_requires 'Digest::SHA';
build_requires 'File::Spec';

#recommended modules
recommends 'Digest' => '1.11';
recommends 'Digest::MD5';
recommends 'Digest::SHA';
recommends 'Crypt::Eksblowfish::Bcrypt';

auto_install;
WriteAll;
