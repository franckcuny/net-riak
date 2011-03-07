package Net::Riak::Role::REST;

# ABSTRACT: role for REST operations

use URI;

use Moose::Role;
use MooseX::Types::Moose 'Bool';
use Net::Riak::Types qw/HTTPResponse HTTPRequest/;
use Data::Dump 'pp';
with qw/Net::Riak::Role::REST::Bucket 
    Net::Riak::Role::REST::Object 
    Net::Riak::Role::REST::Link/;

has http_request => (
    is => 'rw',
    isa => HTTPRequest,
);

has http_response => (
    is => 'rw',
    isa => HTTPResponse,
    handles => {
        is_success => 'is_success',
        status => 'code',
    }
);

has disable_return_body => (
    is => 'rw',
    isa => Bool,
    default => 0
);

sub _build_path {
    my ($self, $path) = @_;
    $path = join('/', @$path);
}

sub _build_uri {
    my ($self, $path, $params) = @_;

    my $uri = URI->new($self->get_host);
    $uri->path($self->_build_path($path));
    $uri->query_form(%$params);
    $uri;
}

# constructs a HTTP::Request
sub new_request {
    my ($self, $method, $path, $params) = @_;
    my $uri = $self->_build_uri($path, $params);
    return HTTP::Request->new($method => $uri);
}

# makes a HTTP::Request returns and stores a HTTP::Response
sub send_request {
    my ($self, $req) = @_;

    $self->http_request($req);
    my $r = $self->useragent->request($req);

    $self->http_response($r);

    if ($ENV{RIAK_VERBOSE}) {
        print STDERR pp($r);
    }

    return $r;
}

sub is_alive {
    my $self     = shift;
    my $request  = $self->new_request('GET', ['ping']);
    my $response = $self->send_request($request);
    $self->is_success ? return 1 : return 0;
}

1;
