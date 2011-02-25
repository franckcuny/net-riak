package Test::Riak;
use strict;
use warnings;
use Test::More 'no_plan';
use_ok 'Net::Riak';

sub import {
    no strict 'refs';
    *{caller()."::test_riak"} = \&{"Test::Riak::test_riak"};
    strict->import;
    warnings->import;
    use Test::More;
}

sub test_riak (&) {
    my ($test_case) = @_;

    diag "Running for PBC";

    if ($ENV{RIAK_PBC_HOST}) {
        my ($host, $port) = split ':', $ENV{RIAK_PBC_HOST};

        my $client = Net::Riak->new(
            transport => 'PBC',
            host  => $host,
            port  => $port,
        );

        isa_ok $client, 'Net::Riak';
        is $client->is_alive, 1, 'connected';
        run_test_case($test_case, $client);
    } else {
        diag "Skipping RIAK_PBC_HOST not set";
    }

    diag "Running for REST";

    if ($ENV{RIAK_REST_HOST}) {
        my $client = Net::Riak->new(host => $ENV{RIAK_REST_HOST});
        isa_ok $client, 'Net::Riak';
        is $client->is_alive, 1, 'connected';
        run_test_case($test_case, $client);
    }
    else {
        diag "Skipping RIAK_REST_HOST not set";
    }
}

sub run_test_case {
    my ($case, $client) = @_;;

    my $bucket = "TEST_RIAK_$$\_".time;

    local $@;
    eval { $case->($client, $bucket) };

    if ($@) {
        ok 0, "$@";
    }

    #TODO add bucket cleanup
}
