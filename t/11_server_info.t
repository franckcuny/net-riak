use lib 't/lib';
use Test::More;
use Test::Riak;
use Data::Dumper;

test_riak {
    my ($client) = @_;

    diag Dumper $client->client->server_info;
 }
