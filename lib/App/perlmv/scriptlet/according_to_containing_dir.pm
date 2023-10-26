package App::perlmv::scriptlet::according_to_containing_dir;

use 5.010001;
use strict;
use warnings;

# AUTHORITY
# DATE
# DIST
# VERSION

our $SCRIPTLET = {
    summary => q[Rename file according to its containing directory's name, e.g. foo/1.txt to foo/foo.txt, or foo/somejpeg to foo/foo.jpg],
    description => <<'MARKDOWN',

In addition to renaming the file according to the name of its container
directory, if the file does not have an extension yet, an extension will be
given by guessing according to its MIME type using <pm:File::MimeInfo::Magic>,
similar to what the `add_extension_according_to_mime_type` scriptlet does.

MARKDOWN
    code => sub {
        package
            App::perlmv::code;

        # we skip directories
        if (-d $_) {
            warn "Directory '$_' skipped\n";
            return;
        }

        # guess file extension
        my ($ext) = /\.(\w+)\z/;
      GUESS_EXT: {
            if (defined $ext) {
                warn "DEBUG: File '$_' already has extension '$ext', skipped guessing extension\n" if $ENV{DEBUG};
                last;
            }

            require File::MimeInfo::Magic;

            my $arg;
            if (-l $_) { open my $fh, "<", $_ or do { warn "Can't open symlink $_: $!, skipped\n"; return }; $arg = $fh } else { $arg = $_ }
            my $type = File::MimeInfo::Magic::mimetype($arg);
            unless ($type) {
                warn "Can't get MIME type from file '$_', skipped guessing extension\n";
                last;
            }
            my @exts = File::MimeInfo::Magic::extensions($type) or die "Bug! extensions() does not return extensions for type '$type'";
            warn "DEBUG: extensions from extensions($type) for file '$_': ".join(", ", @exts)."\n" if $ENV{DEBUG};

            $ext = $exts[0];
        } # GUESS_EXT

        # determine the container directory's name
        no warnings 'once';
        my $dirname = $App::perlmv::code::DIR;
        $dirname =~ s!/\z!!;
        $dirname =~ s!.+/!!;

        defined $ext ? "$dirname.$ext" : $dirname;
    },
};

1;

# ABSTRACT:

=head1 ENVIRONMENT

=head2 DEBUG

Bool. If set to true, will print debugging messages to stderr.


=head1 SEE ALSO

L<App::perlmv::scriptlet::add_extension_according_to_mime_type>

=cut
