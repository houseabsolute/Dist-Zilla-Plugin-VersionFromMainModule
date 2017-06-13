package Dist::Zilla::Plugin::VersionFromMainModule;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.04';

use Module::Metadata 1.000005;

use Moose;

with 'Dist::Zilla::Role::VersionProvider';

sub provide_version {
    my $self = shift;

    my $module = $self->zilla->main_module;
    my $name   = $module->name;

    my $content = $module->encoded_content;
    open my $fh, '<', \$content
        or die $!;
    my $metadata
        = Module::Metadata->new_from_handle( $fh, $name, collect_pod => 0 );
    close $fh or die $!;

    my $ver = $metadata->version
        or $self->log_fatal("Unable to get version from $name");

    $self->log_debug("Setting dist version $ver from $name");

    # We need to stringify this since it can be a version object.
    return "$ver";
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Set the distribution version from your main module's $VERSION

__END__

=head1 SYNOPSIS

  [VersionFromMainModule]

=head1 DESCRIPTION

This plugin sets the distribution version from the C<$VERSION> found in the
distribution's main module, as defined by L<Dist::Zilla>.

This plugin is useful if you want to set the C<$VERSION> in your module(s)
manually or with some sort of post-release "increment the C<$VERSION>" plugin,
rather than letting dzil add the C<$VERSION> based on a setting in the
F<dist.ini>.

=head1 CREDITS

This code is mostly the same as what Christopher J. Madsen's
L<Dist::Zilla::Plugin::VersionFromModule> module does. Unfortunately, that
module is only shipped as part of a larger distribution, and that distribution
has not been updated despite the fact that it is failing tests with newer
versions of dzil.
