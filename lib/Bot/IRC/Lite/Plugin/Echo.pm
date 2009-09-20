package Bot::IRC::Lite::Plugin::Echo;
use Bot::IRC::Lite::Plugin;

our $DEAFULT_FETCH_INTERVAL = 60;

before 'publicmsg'  => sub {
    my ( $self, $connection, $channel, $ircmsg ) = @_;

    # FIXME
    # $ircmsg interface looks ugly
    # need more explicit API
    $self->notice($channel, $ircmsg->{params}->[1]) ;
};

1;

__END__

=head1 NAME

Bot::IRC::Lite::Plugin::Echo - just echo message 

=head1 SYNOPSIS


=head1 DESCRIPTION

=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

