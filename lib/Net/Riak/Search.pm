package Net::Riak::Search;

use Moose;

with 'Net::Riak::Role::Base' => {classes =>
      [{name => 'client', required => 0},]};

sub search {
    my ($self, $params) = @_;
    $self->client->search($params);
};

sub setup_indexing {
    my ($self, $bucket) = @_;
    $self->client->setup_indexing($bucket);
};

1;
