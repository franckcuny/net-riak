package Net::Riak::Role::Hosts;

use Moose::Role;
use Net::Riak::Types qw(RiakHost);

has host => (
    is      => 'rw',
    isa     => RiakHost,
    coerce  => 1,
    default => 'http://127.0.0.1:8098',
);

sub get_host {
    my $self = shift;

    my $choice;
    my $rand = rand;

    for (@{$self->host}) {
        $choice = $_->{node};
        ($rand -= $_->{weight}) <= 0 and last;
    }
    $choice;
}

1;
