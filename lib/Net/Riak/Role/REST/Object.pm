package Net::Riak::Role::REST::Object;

use Moose::Role;

sub store_object {
    my ($self, $w, $dw, $object) = @_;

    my $params = {returnbody => 'true', w => $w, dw => $dw};

    my $request =
      $self->new_request('PUT',
        [$self->prefix, $object->bucket->name, $object->key], $params);

    $request->header('X-Riak-ClientID' => $self->client_id);
    $request->header('Content-Type'    => $object->content_type);

    if ($object->has_vclock) {
        $request->header('X-Riak-Vclock' => $object->vclock);
    }

    if ($object->has_links) {
        $request->header('link' => $object->_links_to_header);
    }

    if (ref $object->data && $object->content_type eq 'application/json') {
        $request->content(JSON::encode_json($object->data));
    }
    else {
        $request->content($object->data);
    }

    my $response = $self->send_request($request);
    $object->populate($response, [200, 204, 300]);
    return $object;
}

sub load_object {
    my ( $self, $params, $object ) = @_;

    my $request =
      $self->new_request( 'GET',
        [ $self->prefix, $object->bucket->name, $object->key ], $params );

    my $response = $self->send_request($request);
    $object->populate( $response, [ 200, 300, 404 ] );
    $object;
}

sub delete_object {
    my ( $self, $params, $object ) = @_;

    my $request =
      $self->new_request( 'DELETE',
        [ $self->prefix, $object->bucket->name, $object->key ], $params );

    my $response = $self->send_request($request);
    $object->populate( $response, [ 204, 404 ] );
    $object;
}

1;
