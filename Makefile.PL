
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A framework for implementing Git hooks.",
  "AUTHOR" => "Gustavo L. de M. Chaves <gnustavo\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Config" => 0,
    "Cwd" => 0,
    "English" => 0,
    "File::Copy" => 0,
    "File::Path" => 0,
    "File::Slurp" => 0,
    "File::Temp" => 0,
    "Test::More" => 0,
    "URI::file" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Git-Hooks",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Git::Hooks",
  "PREREQ_PM" => {
    "App::gh::Git" => 0,
    "Carp" => 0,
    "Data::Util" => 0,
    "Error" => 0,
    "Exporter" => 0,
    "File::Basename" => 0,
    "File::Spec::Functions" => 0,
    "Git" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



