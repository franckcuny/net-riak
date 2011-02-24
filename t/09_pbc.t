use strict;
use warnings;

use Test::More;
use Net::Riak;

BEGIN {
  unless ($ENV{RIAK_PBC_HOST}) {
    require Test::More;
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
isa_ok $bucket, 'Net::Riak::Bucket';

# set properties for bucket
ok $bucket->set_properties(
    {
        n_val      => 2,
        allow_mult => 1,
    }
  ),
  'set properties ok';

# get properties for bucket
my $prop = $bucket->get_properties;
is $prop->{n_val},      2, 'got property n_val';
is $prop->{allow_mult}, 1, 'got property mult';

# n_val method
$bucket->n_val(3);
$prop = $bucket->get_properties;
is $prop->{n_val}, 3, 'got property n_val';

$bucket->new_object( "bob" => { 'name' => 'bob', age => 23 } )->store;

# list keys
is scalar( $bucket->get_keys ), 1, 'returns key';

my $obj = $bucket->get('bob');
isa_ok $obj, 'Net::Riak::Object'; 
is $obj->data->{name}, 'bob', 'retrieved object';
is $obj->data->{age}, 23, 'retrieved object';

done_testing();
