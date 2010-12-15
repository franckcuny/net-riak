package Net::Riak::Role::PBC;

use Moose::Role;

with qw(
  Net::Riak::Role::PBC::Message
  Net::Riak::Role::PBC::Bucket
  Net::Riak::Role::PBC::Object);

use Net::Riak::Types 'Socket';
use IO::Socket::INET;

has [qw/r w dw/] => (
    is      => 'rw',
    isa     => 'Int',
    default => 2
);

has socket => (
    is => 'rw',
    isa => Socket,
    predicate => 'has_socket',
);

sub is_alive {
    my $self = shift;
    return $self->send_message('PingReq');
}

sub connected {
    my $self = shift;
    return $self->has_socket && $self->socket->connected ? 1 : 0;
}

sub connect {
    my $self = shift;
    return if $self->has_socket && $self->connected;

    $self->socket(
        IO::Socket::INET->new(
            PeerAddr => 'localhost',
            PeerPort => '8087',
            Proto    => 'tcp',
            Timeout  => 30,
        )
    );
}

1;
    
