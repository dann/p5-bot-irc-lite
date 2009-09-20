package Bot::IRC::Lite::Plugin::JSONRPC;
use Bot::IRC::Lite::Plugin;
use AnyEvent::JSONRPC::Lite;

after 'connect_to_server' => sub {
    my $self   = shift;
    my $config = $self->plugin_config('JSONRPC');
    my $server = jsonrpc_server $config->{server}, $config->{port};
    $server->reg_cb(
        notify => sub {
            my ( $res_cv, @params ) = @_;
            my $message = join " ", @params;
            $self->notice($config->{channel}, $message) ;
        },
    );
};

1;

__END__

=head1 NAME

Bot::IRC::Lite::Plugin::JSONRPC - notify the message from JSONRPC client to IRC channel

=head1 SYNOPSIS

  plugins
    - module: JSONRPC
      config:
        server: 127.0.0.1
        port: 7777
        channel: '#test'

=head1 DESCRIPTION

=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

