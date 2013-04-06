package Net::Riak::Role::REST::MapReduce;
use Moose::Role;
use JSON;
use Data::Dumper;

sub execute_job {
    my ($self, $job, $timeout) = @_;

    # save existing timeout value.
    my $ua_timeout = $self->useragent->timeout();

    if ($timeout) {
        if ($ua_timeout < ($timeout/1000)) {
            $self->useragent->timeout(int($timeout/1000));
        }
        $job->{timeout} = $timeout;
    }

    my $content = JSON::encode_json($job);

    my $request = $self->new_request(
        'POST', [$self->mapred_prefix]
    );
    $request->content($content);
    $request->header( 'Content-Type' => 'application/json' );

    my $response = $self->send_request($request);

    # restore time out value
    if ( $timeout && ( $ua_timeout != $self->useragent->timeout() ) ) {
        $self->useragent->timeout($ua_timeout);
    }

    unless ($response->is_success) {
        die "MapReduce query failed: ".$response->status_line;
    }

    return JSON::decode_json($response->content);
}

1;
