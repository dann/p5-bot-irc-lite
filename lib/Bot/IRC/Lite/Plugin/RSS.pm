package Bot::IRC::Lite::Plugin::RSS;
use Bot::IRC::Lite::Plugin;
use AnyEvent::Feed;
use Encode qw(encode);

our $DEAFULT_FETCH_INTERVAL = 60;

after 'connect_to_channels' => sub {
    my $self     = shift;
    my $config   = $self->plugin_config('RSS');
    my $interval = $config->{interval} || $DEAFULT_FETCH_INTERVAL;
    foreach my $channel ( @{ $config->{subscriptions} || [] } ) {
        foreach my $url ( @{ $channel->{urls} || [] } ) {
            AnyEvent::Feed->new(
                url      => $url,
                interval => $interval,
                on_fetch => sub {
                    my ( $feed_reader, $new_entries, $feed, $error ) = @_;
                    if ( defined $error ) {
                        print "ERROR: $error\n";
                        return;
                    }
                    for my $entry (@$new_entries) {
                        my $entry_title
                            = encode( $self->charset, $entry->[1]->title );
                        $self->connection->send_chan(
                            $channel->{channel}, "NOTICE",
                            $channel->{channel}, $entry_title
                        );
                    }
                }
            );
        }
    }
};

1;

__END__

=head1 NAME

Bot::IRC::Lite::Plugin::RSS - subscribe RSS and send title to the channel

=head1 SYNOPSIS

  plugins:
    - module: RSS
      config:
        interval: 600
        subscriptions:
          - channel: #test1
            urls:
              - http://dann.g.hatena.ne.jp/dann/rss
          - channel: #test2
            urls:
              - http://dann.g.hatena.ne.jp/dann/rss

=head1 DESCRIPTION


=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>


=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

