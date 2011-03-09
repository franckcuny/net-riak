package Net::Riak::Role::PBC::Object;

use JSON;
use Moose::Role;

sub store_object {
    my ($self, $w, $dw, $object) = @_;

    my $value = (ref $object->data && $object->content_type eq 'application/json') 
            ? JSON::encode_json($object->data) : $object->data;

    my $content = {
        content_type => $object->content_type,
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
            bucket => $object->bucket->name,
            key    => $object->key,
            r      => $params->{r},
        }
    );

    $self->populate_object($object, $resp);
    return $object;
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

sub populate_object {
    my ( $self, $object, $resp) = @_;
    
    my $content = $resp->content ? $resp->content->[0] : undef ;

    return unless $content and $resp->vclock;

    $object->vclock($resp->vclock);
    $object->vtag($content->vtag);
    $object->content_type($content->content_type);

    my $data = ($object->content_type eq 'application/json') 
        ? JSON::decode_json($content->value) : $content->value;

    $object->data($data);
}

1;
