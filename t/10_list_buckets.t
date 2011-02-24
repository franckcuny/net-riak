use strict;
use warnings;

use Test::More;
use Net::Riak;

BEGIN {
  unless ($ENV{RIAK_PBC_HOST}) {
    Test::More::plan(skip_all => 'RIAK_REST_HOST not set.. skipping');
  }
}

my ($host, $port) = split ':', $ENV{RIAK_PBC_HOST};

my $client = Net::Riak->new(
    transport => 'PBC',
    host  => $host,
    port  => $port,
);

ok $client->is_alive;

my $bucket = $client->bucket("TEST_$$\_foo");
ok $bucket->new_object( "bob" => { 'name' => 'bob', age => 23 } )->store, 'store';

$bucket = $client->bucket("TEST_$$\_foo1");
ok $bucket->new_object( "bob" => { 'name' => 'bob', age => 23 } )->store, 'store';

ok scalar( $client->all_buckets) >= 2, 'listed buckets';

done_testing();
