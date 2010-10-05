package Net::Riak::Client;

use Moose;
use MIME::Base64;
use Moose::Util::TypeConstraints;

class_type 'HTTP::Request';
class_type 'HTTP::Response';

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
    isa => 'HTTP::Request',
); 

has http_response => (
    is => 'rw',
    isa => 'HTTP::Response',
    handles => ['is_success']
); 

with 'Net::Riak::Role::UserAgent';
with qw/
  Net::Riak::Role::REST
  Net::Riak::Role::Hosts
  /;



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
