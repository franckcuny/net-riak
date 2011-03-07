package Net::Riak::Role::REST::Link;
use Moose::Role;
use Net::Riak::Link;
use Net::Riak::Bucket;

sub _populate_links {
    my ($self, $object, $links) = @_;

    for my $link (split(',', $links)) {
        if ($link
            =~ /\<\/([^\/]+)\/([^\/]+)\/([^\/]+)\>; ?riaktag=\"([^\']+)\"/)
        {
            my $bucket = $2;
            my $key    = $3;
            my $tag    = $4;
            my $l      = Net::Riak::Link->new(
                bucket => Net::Riak::Bucket->new(
                    name   => $bucket,
                    client => $self
                ),
                key => $key,
                tag => $tag
            );
            $object->add_link($l);
        }
    }
}

sub _links_to_header {
    my ($self, $object) = @_;
    join(', ', map { $self->link_to_header($_) } $object->links);
}

sub link_to_header {
    my ($self, $link) = @_;

    my $link_header = '';
    $link_header .= '</';
    $link_header .= $self->prefix . '/';
    $link_header .= $link->bucket->name . '/';
    $link_header .= $link->key . '>; riaktag="';
    $link_header .= $link->tag . '"';
    return $link_header;
}

1;
