-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Apr 29 20:08:54 2010
-- 


BEGIN TRANSACTION;

--
-- Table: tablea
--
CREATE TABLE tablea (
  id INTEGER PRIMARY KEY NOT NULL,
  conflicting_name char(43) NOT NULL
);

--
-- Table: tableb
--
CREATE TABLE tableb (
  id INTEGER PRIMARY KEY NOT NULL,
  conflicting_name char(43) NOT NULL
);

--
-- Table: test
--
CREATE TABLE test (
  id INTEGER PRIMARY KEY NOT NULL,
  dummy_col char(43) NOT NULL,
  sha1_hex char(40),
  sha1_b64 char(27),
  sha256_hex char(64),
  sha256_b64 char(43),
  sha256_b64_salted char(57),
  bcrypt_1 text,
  bcrypt_2 text
);

COMMIT;
