use strict;
use warnings;

use Test::More;
use Net::Riak;

plan tests => 6;

my $client = Net::Riak->new(
    transport => 'PBC',
    hostname  => 'localhost',
    port      => '8087',
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

for ( 1 .. 300 ) {
    $bucket->new_object( "bob$_" => { 'name' => 'bob', age => 23 } )->store;
}

# list keys
is scalar( $bucket->get_keys ), 300, 'returns 300 keys';
