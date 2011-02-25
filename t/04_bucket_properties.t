use lib 't/lib';
use Test::More;
use Test::Riak;

test_riak {
    my ($client, $bucket_name) = @_;

    my $bucket = $client->bucket($bucket_name);
    $bucket->allow_multiples(1);
    my $props = $bucket->get_properties;
    my $res = $bucket->allow_multiples;
    $bucket->n_val(3);
    is $bucket->n_val, 3, 'n_val is set to 3';
    $bucket->set_properties({allow_mult => 0, "n_val" => 2});
    $res = $bucket->allow_multiples;
    ok !$bucket->allow_multiples, "don't allow multiple anymore";
    is $bucket->n_val, 2, 'n_val is set to 2';
}


