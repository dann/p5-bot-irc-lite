package Bot::IRC::Lite::Plugin::Twitter::TrackHashTag;
use Bot::IRC::Lite::Plugin;
use AnyEvent::Twitter::Stream;

after 'connect_to_channels' => sub {
    my $self   = shift;
    my $config = $self->plugin_config('Twitter::TrackHashTag');
    foreach my $subscription ( @{ $config->{subscriptions} || [] } ) {
        my $hashtags = join ',', @{ $subscription->{hashtags} || [] };
        my $streamer = AnyEvent::Twitter::Stream->new(
            username => $config->{user},
            password => $config->{password},
            method   => 'filter',
            track    => $hashtags,
            on_tweet => sub {
                my $tweet = shift;
                $self->notice( $subscription->{channel},
                    "$tweet->{user}{screen_name}: $tweet->{text}" );
            },
            on_error => sub {
                my $error = shift;
                print "ERROR: $error\n";
                $self->condvar->send;
            },
            on_eof => sub {
                $self->condvar->send;
            },
        );
    }
};

1;

__END__

=head1 NAME

Bot::IRC::Lite::Plugin::Twitter::TrackHashTag - track hash tag of twitter 

=head1 SYNOPSIS

  plugins:
    - module: Twitter::HashTag
      config:
        user: username
        password: password
        subscriptions:
          - channel: #test1
            hashtags:
              - '#perl'
              - '#perl6'

=head1 DESCRIPTION


=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>


=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

