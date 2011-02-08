package Net::Riak::Role::UserAgent;

# ABSTRACT: useragent for Net::Riak

use Moose::Role;
use LWP::UserAgent;
use LWP::ConnCache;

our $CONN_CACHE;

sub connection_cache { $CONN_CACHE ||= LWP::ConnCache->new }

has useragent => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    lazy    => 1,
    default => sub {
        my $self = shift;

        # The Links header Riak returns (esp. for buckets) can get really long,
        # so here increase the MaxLineLength LWP will accept (default = 8192)
        my %opts = @LWP::Protocol::http::EXTRA_SOCK_OPTS;
        $opts{MaxLineLength} = 65_536;
        @LWP::Protocol::http::EXTRA_SOCK_OPTS = %opts;

        my $ua = LWP::UserAgent->new(
            timeout => $self->ua_timeout
        );

        $ua->conn_cache(__PACKAGE__->connection_cache);

        $ua;
    }
);

1;
