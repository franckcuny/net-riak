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

1;
