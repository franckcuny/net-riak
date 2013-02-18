package Net::Riak::Role::UserAgent;
{
  $Net::Riak::Role::UserAgent::VERSION = '0.1600';
}

# ABSTRACT: useragent for Net::Riak

use Moose::Role;
use LWP::UserAgent;
use LWP::ConnCache;
use IO::Socket::SSL;
use Data::Dumper;

our $CONN_CACHE;

sub connection_cache { $CONN_CACHE ||= LWP::ConnCache->new }

has ua_timeout => (
    is  => 'rw',
    isa => 'Int',
    default => 120
);

has ssl_opts => (
    is => 'rw',
    isa => 'HashRef'
);

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
        my $ua = undef;

        if ( !$self->ssl ) {
            $ua = LWP::UserAgent->new(
                timeout => $self->ua_timeout,
                keep_alive => 1,
            );
        } else {
            $ua = LWP::UserAgent->new(
                timeout => $self->ua_timeout,
                keep_alive => 1,
                ssl_opts => $self->ssl_opts
            );
        }

        $ua->conn_cache(__PACKAGE__->connection_cache);

        $ua;
    }
);

1;
