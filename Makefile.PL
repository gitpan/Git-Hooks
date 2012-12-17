use strict;
use warnings;

use 5.010;

# Check if we have a proper git
chomp(my $git_version = `git version`);
if ($? == -1) {
    warn "Failed to execute 'git version': $!\n";
    exit 0;
} elsif ($? != 0) {
    warn "Command 'git version' died with exit code=$?\n";
    exit 0;
} elsif (my ($major, $minor) = ($git_version =~ /(\d+)\.(\d+)/)) {
    if ($major < 1 || $major == 1 && $minor < 5) {
	warn "Don't support gits older than 1.5. Your version is $git_version.\n";
	exit 0;
    }
} else {
    warn "Couldn't parse git version: '$git_version'\n";
    exit 0;
}

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'A framework for implementing Git hooks.',
  'AUTHOR' => 'Gustavo L. de M. Chaves <gnustavo@cpan.org>',
  'BUILD_REQUIRES' => {
    'Config' => '0',
    'Cwd' => '0',
    'File::Copy' => '0',
    'File::Path' => '2.08',
    'Test::More' => '0',
    'URI::file' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'DISTNAME' => 'Git-Hooks',
  'LICENSE' => 'perl',
  'MIN_PERL_VERSION' => '5.010',
  'NAME' => 'Git::Hooks',
  'PREREQ_PM' => {
    'App::gh' => '0.56',
    'App::gh::Git' => '0',
    'Carp' => '0',
    'Data::Util' => '0',
    'Error' => '0',
    'Exporter' => '0',
    'File::Basename' => '0',
    'File::Slurp' => '0',
    'File::Spec::Functions' => '0',
    'File::Temp' => '0',
    'JIRA::Client' => '0',
    'List::MoreUtils' => '0',
    'parent' => '0',
    'strict' => '0',
    'utf8' => '0',
    'warnings' => '0'
  },
  'VERSION' => '0.024',
  'test' => {
    'TESTS' => 't/*.t'
  },
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



