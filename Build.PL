
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601",
    "Test::More" => "0.96"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Add logging to DBI method calls, etc",
  "dist_author" => [
    "Steven Haryanto <stevenharyanto\@gmail.com>"
  ],
  "dist_name" => "Log-Any-For-DBI",
  "dist_version" => "0.03",
  "license" => "perl",
  "module_name" => "Log::Any::For::DBI",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Log::Any" => 0,
    "Log::Any::For::Class" => "0.04",
    "perl" => "5.010000"
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
