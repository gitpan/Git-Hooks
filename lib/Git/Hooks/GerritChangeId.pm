#!/usr/bin/env perl

package Git::Hooks::GerritChangeId;
{
  $Git::Hooks::GerritChangeId::VERSION = '1.6.1';
}
# ABSTRACT: Git::Hooks plugin to insert a Change-Id in a commit message.

use 5.010;
use utf8;
use strict;
use warnings;
use Git::Hooks qw/:DEFAULT :utils/;
use Git::More::Message;
use Path::Tiny;
use Carp;
use Error qw(:try);

my $PKG = __PACKAGE__;
(my $CFG = __PACKAGE__) =~ s/.*::/githooks./;

##########

sub gen_change_id {
    my ($git, $msg) = @_;

    my $filename = Path::Tiny->tempfile(UNLINK => 1);
    open my $fh, '>', $filename ## no critic (RequireBriefOpen)
        or croak "$PKG: internal error: can't open $filename for writing: $!";

    foreach my $info (
        [ tree      => [qw/write-tree/] ],
        [ parent    => [qw/rev-parse HEAD^0/] ],
        [ author    => [qw/var GIT_AUTHOR_IDENT/] ],
        [ committer => [qw/var GIT_COMMITTER_IDENT/] ],
    ) {
        try {
            $fh->print($info->[0], ' ', scalar($git->command($info->[1], {STDERR => 0})));
        } otherwise {
            # Can't find info. That's ok.
        };
    }

    $fh->print("\n", $msg);
    $fh->close();

    return 'I' . $git->hash_object(commit => $filename);
}

sub insert_change_id {
    my ($git, $msg) = @_;

    # Does Change-Id: already exist? if so, exit (no change).
    return if $msg =~ /^Change-Id:/im;

    my $cmsg = Git::More::Message->new($msg);

    # Don't mess with the message if it's empty.
    if ($cmsg->title !~ /\S/ && $cmsg->body !~ /\S/) {
        # (Signed-off-by footers don't count.)
        my @footer = $cmsg->get_footer_keys;
        return if @footer == 0 || @footer == 1 && $footer[0] eq 'signed-off-by';
    }

    # Insert the Change-Id footer
    $cmsg->add_footer_values('Change-Id' => gen_change_id($git, $cmsg->as_string));

    return $cmsg->as_string;
};

sub rewrite_message {
    my ($git, $commit_msg_file) = @_;

    my $msg = eval { $git->read_commit_msg_file($commit_msg_file) };
    unless (defined $msg) {
        $git->error($PKG, "cannot read commit message file '$commit_msg_file'", $@);
        return 0;
    }

    # Rewrite the message file
    if (my $new_msg = insert_change_id($git, $msg)) {
        $git->write_commit_msg_file($commit_msg_file, $new_msg);
    }

    return 1;
}

# Install hooks
COMMIT_MSG \&rewrite_message;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Git::Hooks::GerritChangeId - Git::Hooks plugin to insert a Change-Id in a commit message.

=head1 VERSION

version 1.6.1

=head1 DESCRIPTION

This Git::Hooks plugin hooks itself to the C<commit-msg> hook. It is a
reimplementation of Gerrit's official commit-msg hook for inserting
change-ids in git commit messages.  It's does not produce the same
C<Change-Id> for the same message, but this is not really necessary,
since it keeps existing Change-Id footers unmodified.

(What follows is a partial copy of that document's DESCRIPTION
section.)

This plugin automatically inserts a globally unique Change-Id tag in
the footer of a commit message. When present, Gerrit uses this tag to
track commits across cherry-picks and rebases.

After the hook has been installed in the user's local Git repository
for a project, the hook will modify a commit message such as:

    Improve foo widget by attaching a bar.
    
    We want a bar, because it improves the foo by providing more
    wizbangery to the dowhatimeanery.
    
    Signed-off-by: A. U. Thor <author@example.com>

by inserting a new C<Change-Id: > line in the footer:

    Improve foo widget by attaching a bar.
    
    We want a bar, because it improves the foo by providing more
    wizbangery to the dowhatimeanery.
    
    Change-Id: Ic8aaa0728a43936cd4c6e1ed590e01ba8f0fbf5b
    Signed-off-by: A. U. Thor <author@example.com>

The hook implementation is reasonably intelligent at inserting the
Change-Id line before any Signed-off-by or Acked-by lines placed at
the end of the commit message by the author, but if no such lines are
present then it will just insert a blank line, and add the Change-Id
at the bottom of the message.

If a Change-Id line is already present in the message footer, the
script will do nothing, leaving the existing Change-Id
unmodified. This permits amending an existing commit, or allows the
user to insert the Change-Id manually after copying it from an
existing change viewed on the web.

To enable the plugin you should add it to the githooks.plugin
configuration option:

    git config --add githooks.plugin GerritChangeId

=for Pod::Coverage gen_change_id insert_change_id

=head1 NAME

Git::Hooks::GerritChangeId - Git::Hooks plugin to insert a Change-Id in a commit message.

=head1 CONFIGURATION

There's no configuration needed or provided.

=head1 EXPORTS

This module exports one routine that can be used directly without
using all of Git::Hooks infrastructure.

=head2 rewrite_message GIT, MSGFILE

This is the routine used to implement the C<commit-msg> hook. It needs
a C<Git::More> object and the name of a file containing the commit
message.

=head1 REFERENCES

L<Gerrit's Home Page|http://gerrit.googlecode.com/>.

L<Gerrit's official commit-msg
hook|https://gerrit.googlesource.com/gerrit/+/master/gerrit-server/src/main/resources/com/google/gerrit/server/tools/root/hooks/commit-msg>.

L<Gerrit's official hook
documentation|https://gerrit.googlesource.com/gerrit/+/master/Documentation/cmd-hook-commit-msg.txt>.

=head1 AUTHOR

Gustavo L. de M. Chaves <gnustavo@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by CPqD <www.cpqd.com.br>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
