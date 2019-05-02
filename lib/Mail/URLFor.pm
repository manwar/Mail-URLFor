package Mail::URLFor;
use strict;
use Module::Pluggable
    sub_name => '_plugins',
    instantiate => 'new',
    ;
use Moo 2;
use Filter::signatures;
no warnings 'experimental::signatures';
use feature 'signatures';

our $VERSION = '0.01';

=head1 NAME

Mail::URLFor - create links to emails for native clients

=head1 SYNOPSIS

    my $links = Mail::URLFor->new();
    
    my $messageid = 'mail.abcdef.123456@example.com';
    
    my $urls = $links->urls_for($messageid);
    
    for my $client (keys %$urls) {
        print "$client: $urls->{$client}\n";
    };

=head1 DESCRIPTION

This module allows you to create (clickable) URLs to emails that
will open in the respective (native) client or Gmail.

This is useful if you have a web application but still want to connect
an object on the web page with an email in a local mail client.
    
=cut

our @default_links;

=head1 METHODS

=head2 C<< Mail::URLFor->new >>

    # Only link to mails on Gmail
    my $links = Mail::URLFor->new(
        clients => [Mail::URLFor::Plugin::Gmail->new],
    );

=head3 Options

=over 4

=item B<<clients>>

Arrayref of the classes (or instances) of mail clients to
render links for.

Defaults to all C<::Plugin> classes.

=back

=cut

has clients => (
    is => 'ro',
    default => sub {[ $_[0]->_plugins() ]},
);

=head2 C<< ->url_for( $rfc822messageid, $client = 'Gmail' ) >>

    my $url = $links->url_for( '1234.abc@example.com', 'Gmail' );
    
Renders the URL using the moniker of the plugin.

Returns something that should mostly be treated as an opaque string.
Returns C<undef>, if the moniker is unknown.

Currently, the returned string is always
percent-encoded already, but this may change in the future.

=cut

sub url_for( $self, $rfc822messageid, $client = 'Gmail' ) {
    $self->urls_for( $rfc822messageid )->{$client}
}

=head2 C<< ->urls_for( $rfc822messageid ) >>

    my $urls = $links->urls_for( '1234.abc@example.com' );
    print $urls->{'Gmail'};

=cut

sub urls_for( $self, $rfc822messageid, @clients ) {
    if( ! @clients) {
        @clients = @{ $self->clients };
    };
    +{
        map { $_->moniker => $_->render( $rfc822messageid )} @clients
    }
}

1;

__END__

