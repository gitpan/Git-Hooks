# -*- cperl -*-

use 5.010;
use strict;
use warnings;
use lib 't';
use Test::More tests => 1;

BEGIN { require "test-functions.pl" };

my ($repo, $file, $clone) = new_repos();
install_hooks($repo, <<'EOF');
COMMIT_MSG {
    my ($git, $msg_file) = @_;
    die "commit-msg died!\n";
};
EOF

$file->append("new line\n");
$repo->command(add => $file);
test_nok('cannot commit', $repo,
	 'commit', '-q', '-m', 'new commit');
