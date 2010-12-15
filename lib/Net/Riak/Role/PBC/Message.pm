package Net::Riak::Role::PBC::Message;

use Moose::Role;
use Net::Riak::Transport::PBC::Message;

sub send_message {
    my ( $self, $type, $params, $cb ) = @_;

    $self->connect unless $self->connected;

    my $message = Net::Riak::Transport::PBC::Message->new(
        message_type => $type,
        params       => $params || {},
    );

    $message->socket( $self->socket );

    return $message->send($cb);
}

1;
