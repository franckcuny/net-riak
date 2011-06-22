package Net::Riak::Search;

# ABSTRACT: the riaklink object represents a link from one Riak object to another

use Moose;

with 'Net::Riak::Role::Base' => {classes =>
      [{name => 'client', required => 0},]};

sub search {
    my ($self, $params) = @_;
    $self->client->search($params);
};

1;
