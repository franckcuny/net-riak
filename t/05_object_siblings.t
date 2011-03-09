use lib 't/lib';
use Test::More;
use Test::Riak;


test_riak {
    my ($client, $bucket_name) = @_;

    my $bucket = $client->bucket($bucket_name);
    $bucket->allow_multiples(1);
    ok $bucket->allow_multiples, 'multiples set to 1';
    my $obj = $bucket->get('foo');
    $obj->delete;
   
    for(1..5) {
        my $client = new_riak_client();
        my $bucket = $client->bucket($bucket_name);
        $obj = $bucket->new_object('foo', [int(rand(100))]);
        $obj->store;
    }

    # check we got 5 siblings
    ok $obj->has_siblings, 'object has siblings';
    $obj = $bucket->get('foo');
    my $siblings_count = $obj->get_siblings;
    is $siblings_count, 5, 'got 5 siblings';
   
    # test set/get
    my @siblings = $obj->siblings;
    my $obj3 = $obj->sibling(3);
    is_deeply $obj3->data, $obj->sibling(3)->data;
    $obj3 = $obj->sibling(3);
    $obj3->store;
    $obj->load;
    is_deeply $obj->data, $obj3->data;
    $obj->delete;
}
