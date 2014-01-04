#---------------------------------------------------------------------
package Apache2::HttpEquiv;
#
# Copyright 2012 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
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
# ABSTRACT: Convert <meta http-equiv=...> to HTTP headers
#---------------------------------------------------------------------

use 5.008;
use strict;
use Apache2::Const -compile => qw(OK DECLINED);
use HTML::PullParser;

#=====================================================================
# Package Global Variables:

our $VERSION = '1.00';
# This file is part of {{$dist}} {{$dist_version}} ({{$date}})

#=====================================================================
sub handler
{
  my $r = shift;

  return Apache2::Const::DECLINED
      unless $r->is_initial_req
         and $r->content_type eq "text/html"
         and open(my $file, '<:encoding(latin1)', $r->filename);

  my ($p, $token, $header) = HTML::PullParser->new(
    file  => $file,
    start => 'tag, attr',
    end   => 'tag',
  );

  my $content_type;

  while ($token = $p->get_token) {
    if ($token->[0] eq 'meta') {
      if ($header = $token->[1]{'charset'} and not defined $content_type) {
        $content_type = "text/html; charset=$header";
      } # end if <meta charset=...>
      elsif ($header = $token->[1]{'http-equiv'}) {
        if ($header eq 'Content-Type' and not defined $content_type) {
          $content_type = $token->[1]{content};
          # text/xhtml is not a valid content type:
          $content_type =~ s!^text/xhtml(?=\s|;|\z)!text/html!i;
        } else {
          $r->headers_out->set($header => $token->[1]{content});
        }
      } # end elsif <meta http-equiv=...>
    } # end if <meta> tag
    last if $token->[0] eq 'body' or $token->[0] eq '/head';
  } # end while get_token

  $r->content_type($content_type) if $content_type;

  close($file);

  return Apache2::Const::OK;
} # end handler

#=====================================================================
# Package Return Value:

1;

__END__

=head1 SYNOPSIS

In your Apache config:

  <Location />
    PerlFixupHandler Apache2::HttpEquiv
  </Location>

=head1 DESCRIPTION

Apache2::HttpEquiv provides a PerlFixupHandler for mod_perl 2 that turns
C<< <meta http-equiv="Header-Name" content="Header Value"> >> into an actual
HTTP header.  It also looks for C<< <meta charset="..."> >> and uses it to
set the Content-Type to C<text/html; charset=...>.

If the file claims its Content-Type is 'text/xhtml', the Content-Type
is set to 'text/html' instead.  'text/xhtml' is not a valid
Content-Type, and any file that claims it is probably too broken to
parse as 'application/xhtml+xml'.

This works only for static HTML files (that Apache has identified as
'text/html').  If you're generating dynamic content, you should be
generating the appropriate Content-Type and other headers at the same
time.

=for Pod::Coverage
handler

=cut
