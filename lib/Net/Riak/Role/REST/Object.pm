package Net::Riak::Role::REST::Object;

use Moose::Role;
use JSON;
has _headers     => (is => 'rw', isa => 'HTTP::Response',);

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
    $object->populate($response, [200, 201, 204, 300]);
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

sub populate {
    my ($self, $http_response, $expected) = @_;

    $self->clear;

    return if (!$http_response);

    my $status = $http_response->code;
    $self->_headers($http_response);
    $self->status($status);

    $self->data($http_response->content);

    if (!grep { $status == $_ } @$expected) {
        confess "Expected status "
          . (join(', ', @$expected))
          . ", received $status"
    }

    if ($status == 404) {
        $self->clear;
        return;
    }

    $self->exists(1);

    if ($http_response->header('link')) {
        $self->_populate_links($http_response->header('link'));
    }

    if ($status == 300) {
        my @siblings = split("\n", $self->data);
        shift @siblings;
        $self->siblings(\@siblings);
    }
    
    if ($status == 201) {
        my $location = $http_response->header('location');
        my ($key)    = ($location =~ m!/([^/]+)$!);
        $self->key($key);
    } 
    

    if ($status == 200 || $status == 201) {
        $self->content_type($http_response->content_type)
            if $http_response->content_type;
        $self->data(JSON::decode_json($self->data))
            if $self->content_type eq 'application/json';
        $self->vclock($http_response->header('X-Riak-Vclock'));
    }
}
1;
