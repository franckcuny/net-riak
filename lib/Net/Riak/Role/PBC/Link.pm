package Net::Riak::Role::PBC::Link;
use Moose::Role;
use Net::Riak::Link;
use Net::Riak::Bucket;

sub _populate_links {
    my ($self, $object, $links) = @_;

    for my $link (@$links) {
        my $l = Net::Riak::Link->new(
            bucket => Net::Riak::Bucket->new(
                name   => $link->bucket,
                client => $self
            ),
            key => $link->key,
            tag => $link->tag
        );
        $object->add_link($l);
    }
}

sub _links_for_message {
    my ($self, $object) = @_;

    return [
        map { {
                tag => $_->tag,
                key => $_->key,
                bucket => $_->bucket->name
            }
        } $object->all_links
    ]
}

1;
