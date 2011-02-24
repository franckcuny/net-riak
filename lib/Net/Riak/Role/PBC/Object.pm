package Net::Riak::Role::PBC::Object;

use JSON;
use Moose::Role;

sub store_object {
    my ($self, $w, $dw, $object) = @_;

    my $value = (ref $object->data && $object->content_type eq 'application/json') 
            ? JSON::encode_json($object->data) : $object->data;

    my $content = {
        value => $value,
        links => undef,
        usermeta => undef
    };

    $self->send_message(
        PutReq => {
            bucket  => $object->bucket->name,
            key     => $object->key,
            content => $content,
        }
    );
    return $object;
}

sub load_object {
    my ( $self, $params, $object ) = @_;

    my $resp = $self->send_message(
        GetReq => {
            bucket => $object->bucket,
            key    => $object->key,
            r      => $params->{r},
        }
    );

    $object->populate($resp);
    $object;
}

sub delete_object {
    my ( $self, $params, $object ) = @_;

    return $self->send_message(
        DelReq => {
            bucket => $object->bucket,
            key    => $object->key,
            rw     => $params->{w},
        }
    );
}

1;
