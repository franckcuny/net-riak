package Net::Riak::Role::REST::Search;
use Moose::Role;
use JSON;

sub search {
    my ( $self, $params) = @_;

    my $request;
    $request =
      $self->new_request( 'GET',
        [ $self->search_prefix, "select" ], $params ) unless $params->{index};
    $request =
      $self->new_request( 'GET',
        [ $self->search_prefix, $params->{index}, "select" ], $params ) if $params->{index};

    my $http_response = $self->send_request($request);

    return if (!$http_response);

    my $status = $http_response->code;
    if ($status == 404) {
        return;
    }
    JSON::decode_json($http_response->content);
};


1;
