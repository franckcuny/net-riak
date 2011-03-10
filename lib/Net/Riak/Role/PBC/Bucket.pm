package Net::Riak::Role::PBC::Bucket;

use Moose::Role;
use Data::Dumper;

sub get_properties {
    my ( $self, $name, $params ) = @_;
    my $resp = $self->send_message( GetBucketReq => { bucket => $name } );
    return { props =>  { %{ $resp->props } } };
}

sub set_properties {
    my ( $self, $bucket, $props ) = @_;
    return $self->send_message(
        SetBucketReq => {
            bucket => $bucket->name,
            props  => $props
        }
    );
}

sub get_keys {
    my ( $self, $name ) = @_;
    my $keys = [];

    my $res = $self->send_message(
        ListKeysReq => { bucket => $name, },
        sub {
            if ( defined $_[0]->keys ) {
                push @$keys, @{ $_[0]->keys };
            }
        }
    );

    return @$keys;
}



1;

