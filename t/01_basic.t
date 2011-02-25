use strict;
use warnings;
use Test::More;
use Net::Riak;

# test js source map
{
    my $client = Net::Riak->new(host => $ENV{RIAK_REST_HOST});
    my $bucket = $client->bucket($bucket_name);
    my $obj    = $bucket->new_object('foo', [2])->store;
    my $result =
      $client->add($bucket_name, 'foo')
      ->map("function (v) {return [JSON.parse(v.values[0].data)];}")->run;
    is_deeply $result, [[2]], 'got valid result';
}

# XXX javascript named map
# {
#     my $client     = Net::Riak->new();
#     my $bucket     = $client->bucket($bucket_name);
#     my $obj        = $bucket->new_object('foo', [2])->store;
#     my $result = $client->add("bucket", "foo")->map("Riak.mapValuesJson")->run;
#     is_deeply $result, [[2]], 'got valid result';
# }

# javascript source map reduce
{
    my $client = Net::Riak->new(host => $ENV{RIAK_REST_HOST});
    my $bucket = $client->bucket($bucket_name);
    my $obj    = $bucket->new_object('foo', [2])->store;
    $obj = $bucket->new_object('bar', [3])->store;
    $bucket->new_object('baz', [4])->store;
    my $result =
      $client->add($bucket_name, "foo")->add($bucket_name, "bar")
      ->add($bucket_name, "baz")->map("function (v) { return [1]; }")
      ->reduce("function (v) { return [v.length]; }")->run;
    is $result->[0], 3, "success map reduce";
}

# javascript named map reduce
{
    my $client = Net::Riak->new(host => $ENV{RIAK_REST_HOST});
    my $bucket = $client->bucket($bucket_name);
    my $obj    = $bucket->new_object("foo", [2])->store;
    $obj = $bucket->new_object("bar", [3])->store;
    $obj = $bucket->new_object("baz", [4])->store;
    my $result =
      $client->add($bucket_name, "foo")->add($bucket_name, "bar")
      ->add($bucket_name, "baz")->map("Riak.mapValuesJson")
      ->reduce("Riak.reduceSum")->run();
    ok $result->[0];
}

# javascript bucket map reduce
{
    my $client = Net::Riak->new(host => $ENV{RIAK_REST_HOST});
    my $bucket = $client->bucket("bucket_".int(rand(10)));
    $bucket->new_object("foo", [2])->store;
    $bucket->new_object("bar", [3])->store;
    $bucket->new_object("baz", [4])->store;
    my $result =
      $client->add($bucket->name)->map("Riak.mapValuesJson")
      ->reduce("Riak.reduceSum")->run;
    ok $result->[0];
}

# javascript map reduce from object
{
    my $client = Net::Riak->new(host => $ENV{RIAK_REST_HOST});
    my $bucket = $client->bucket($bucket_name);
    $bucket->new_object("foo", [2])->store;
    my $obj = $bucket->get("foo");
    my $result = $obj->map("Riak.mapValuesJson")->run;
    is_deeply $result->[0], [2], 'valid content';
}

# store and get links
{
    my $client = Net::Riak->new(host => $ENV{RIAK_REST_HOST});
    my $bucket = $client->bucket($bucket_name);
    my $obj = $bucket->new_object("foo", [2]);
    my $obj1 = $bucket->new_object("foo1", {test => 1})->store;
    my $obj2 = $bucket->new_object("foo2", {test => 2})->store;
    my $obj3 = $bucket->new_object("foo3", {test => 3})->store;
    $obj->add_link($obj1);
    $obj->add_link($obj2, "tag");
    $obj->add_link($obj3, "tag2!@&");
    $obj->store;
    $obj = $bucket->get("foo");
    my $count = $obj->count_links;
    is $count, 3, 'got 3 links';
}

# link walking
{
    my $client = Net::Riak->new(host => $ENV{RIAK_REST_HOST});
    my $bucket = $client->bucket($bucket_name);
    my $obj    = $bucket->new_object("foo", [2]);
    my $obj1   = $bucket->new_object("foo1", {test => 1})->store;
    my $obj2   = $bucket->new_object("foo2", {test => 2})->store;
    my $obj3   = $bucket->new_object("foo3", {test => 3})->store;
    $obj->add_link($obj1)->add_link($obj2, "tag")->add_link($obj3, "tag2!@&");
    $obj->store;
    $obj = $bucket->get("foo");
    my $results = $obj->link($bucket_name)->run();
    is scalar @$results, 3, 'got 3 links via links walking';
    $results = $obj->link($bucket_name, 'tag')->run;
    is scalar @$results, 1, 'got one link via link walking';
}

done_testing;
