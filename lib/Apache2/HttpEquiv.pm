#---------------------------------------------------------------------
# $Id$
package Apache2::HttpEquiv;
#
# Copyright 2006 Christopher J. Madsen
#
# Author: Christopher J. Madsen <cjm@pobox.com>
# Created: 11 Mar 2006
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# Convert <meta http-equiv=...> to HTTP headers
#---------------------------------------------------------------------

use 5.008;
use strict;
use Apache2::Const -compile => qw(OK DECLINED);

#=====================================================================
# Package Global Variables:

our $VERSION = '0.01';

#=====================================================================
sub handler {
  my $r = shift;
  local(*FILE);

   return Apache2::Const::DECLINED if # don't scan the file if..
      !$r->is_initial_req # a subrequest
          || $r->content_type ne "text/html" # it isn't HTML
              || !open(FILE, '<', $r->filename); # we can't open it

   while(<FILE>) {
      if (m/<META HTTP-EQUIV="([^"]+)"\s+CONTENT="([^"]+)"/i) {
        if ($1 eq 'Content-Type') {
          $r->content_type($2);
        } else {
          $r->headers_out->set($1 => $2);
        }
      }
      last if m!<BODY>|</HEAD>!i; # exit early if in BODY
  }
  close(FILE);
  return Apache2::Const::OK;
} # end handler

#=====================================================================
# Package Return Value:

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Apache2::HttpEquiv - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Apache2::HttpEquiv;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Apache2::HttpEquiv, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Christopher J. Madsen, E<lt>cjm@pobox.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Christopher J. Madsen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
