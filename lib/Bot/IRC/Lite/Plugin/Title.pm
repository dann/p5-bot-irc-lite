package Bot::IRC::Lite::Plugin::Title;
use Bot::IRC::Lite::Plugin;
use LWP::UserAgent;
use URI::Find::UTF8;
use HTTP::Response::Encoding;
use Encode qw(decode);

before 'publicmsg' => sub {
    my ( $self, $connection, $channel, $ircmsg ) = @_;
    my $title_finder = URI::Find::UTF8->new( \&__get_title );
    my $message      = $ircmsg->{params}->[1];
    $title_finder->find(\$message);
    $self->notice( $channel, $message );
};

sub __get_title {
    my ( $uri, $uri_str ) = @_;
    my $ua       = LWP::UserAgent->new;
    my $response = $ua->get($uri);

    if ( $response->is_success ) {
        my $content_type = $response->content_type;
        my $encoding     = $response->encoding;

        my $title;
        if ( $content_type =~ /^text/i ) {
            if ( $response->header('title') ) {
                $title = $response->header('title');
            }
            elsif ( $response->content ) {
                ($title) = $response->content =~ m{<TITLE>(.+?)</TITLE>}is;
            }
            $title = decode( $encoding, $title ) if $encoding;
        }
        $title = '' unless defined $title;
        return $title;
    }
    return;
}

1;

__END__

=head1 NAME

Bot::IRC::Lite::Plugin::Title - notice the title of web page 

=head1 SYNOPSIS

  plugins
    - module: Title

=head1 DESCRIPTION

=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 SEE ALSO

Charsbot

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

