package Net::Riak::Role::PBC::Meta;

use Moose::Role;

sub _populate_metas {
    my ($self, $object, $metas) = @_;

    for my $meta (@$metas) {
        $object->set_meta( $meta->key, $meta->value );
    }
}

sub _metas_for_message {
    my ($self, $object) = @_;

    my @out;
    while ( my ( $k, $v ) = each %{ $object->metadata } ) {
        push @out, { key => $k, value => $v };
    }
    return \@out;

}

1;
