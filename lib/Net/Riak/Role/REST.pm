package Net::Riak::Role::REST;

# ABSTRACT: role for REST operations

use URI;
use MIME::Base64;

use Moose::Role;
use Net::Riak::Types qw/HTTPResponse HTTPRequest/;
with qw/Net::Riak::Role::REST::Bucket Net::Riak::Role::REST::Object/;

has prefix => (
    is      => 'rw',
    isa     => 'Str',
    default => 'riak'
);
has mapred_prefix => (
    is      => 'rw',
    isa     => 'Str',
    default => 'mapred'
);
has [qw/r w dw/] => (
    is      => 'rw',
    isa     => 'Int',
    default => 2
);
has client_id => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);
has http_request => (
    is => 'rw',
    isa => HTTPRequest,
);

has http_response => (
    is => 'rw',
    isa => HTTPResponse,
    handles => ['is_success']
);

has ua_timeout => (
    is  => 'rw',
    isa => 'Int',
    default => 3
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

    return $r;
}

sub _build_client_id {
    "perl_net_riak" . encode_base64(int(rand(10737411824)), '');
}

sub is_alive {
    my $self     = shift;
    my $request  = $self->new_request('GET', ['ping']);
    my $response = $self->send_request($request);
    $self->is_success ? return 1 : return 0;
}

1;
