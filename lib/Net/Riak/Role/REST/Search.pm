package Net::Riak::Role::REST::Search;
use Moose::Role;
use JSON;

sub search {
    my ( $self, $params) = @_;

    my $request;
    $request =
      $self->new_request( 'GET',
        [ $self->search_prefix, "select" ], $params ) unless $params->{index};
    if ( $params->{index} ){
        my $index = delete $params->{index};
        $request =
            $self->new_request( 'GET',
                [ $self->search_prefix, $index, "select" ], $params );
    }
    
    my $http_response = $self->send_request($request);

    return if (!$http_response);

    my $status = $http_response->code;
    if ($status == 404) {
        return;
    }
use YAML::Syck;
warn Dump $http_response;
    JSON::decode_json($http_response->content);
};


1;
