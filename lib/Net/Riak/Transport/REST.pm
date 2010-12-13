package Net::Riak::Transport::REST;

use Moose::Role;

with qw/
  Net::Riak::Role::UserAgent
  Net::Riak::Role::REST
  Net::Riak::Role::Hosts
  /;

1;
