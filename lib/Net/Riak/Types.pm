package Net::Riak::Types;

use MooseX::Types::Moose qw/Str ArrayRef HashRef/;
use MooseX::Types::Structured qw(Tuple Optional Dict);
use MooseX::Types -declare =>
  [qw(Socket Client HTTPResponse HTTPRequest RiakHost)];

class_type Socket,       { class => 'IO::Socket::INET' };
class_type Client,       { class => 'Net::Riak::Client' };
class_type HTTPRequest,  { class => 'HTTP::Request' };
class_type HTTPResponse, { class => 'HTTP::Response' };

subtype RiakHost, as ArrayRef [HashRef];

coerce RiakHost, from Str, via {
    [ { node => $_, weight => 1 } ];
};

coerce RiakHost, from ArrayRef, via {
    warn "DEPRECATED: Support for multiple hosts will be removed in the 0.17 release.";
    my $backends = $_;
    my $weight   = 1 / @$backends;
    [ map { { node => $_, weight => $weight } } @$backends ];
};

coerce RiakHost, from HashRef, via {
    warn "DEPRECATED: Support for multiple hosts will be removed in the 0.17 release.";
    my $backends = $_;
    my $total    = 0;
    $total += $_ for values %$backends;
    [
        map { { node => $_, weight => $backends->{$_} / $total } }
          keys %$backends
    ];
};

1;

