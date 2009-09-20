package Bot::IRC::Lite;
use Mouse;
use AnyEvent;
use AnyEvent::IRC::Client;
use Carp ();
use Encode qw(encode);

our $VERSION = '0.01';

with 'MouseX::Object::Pluggable';

has 'connection' => ( is => 'rw', );

has 'server' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'port' => (
    is      => 'rw',
    isa     => 'Int',
    default => 6667,
);

has 'channels' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 1,
);

has 'nick' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'username' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'bot-irc-lite',
);

has 'name' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'Yet Another IRC Bot',
);

has 'charset' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'utf-8',
);

has 'ignore_list' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {
        [];
    }
);

has 'reconnect_period' => (
    is      => 'rw',
    isa     => 'Int',
    default => 60,
);

has 'hook_methods' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {
        [ 'privatemsg', 'publicmsg', 'connect', 'disconnect' ];
    }
);

has 'plugins' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub {
        [];
    }
);

has 'condvar' => ( is => 'rw', );

sub BUILD {
    my $self = shift;
    $self->_setup;
}

#--------------------------------------------------------------------
# Hook points
#--------------------------------------------------------------------
sub privatemsg {
    my ( $self, $nick, $ircmsg );
}

sub publicmsg {
    my ( $self, $channel, $ircmsg );
}

sub connect {
    my ( $self, $con, $error ) = @_;
    if ( defined $error ) {
        print "Couldn't connect to server: $error\n";
        return;
    }
    print "connected ;)\n";
}

sub disconnect {
    my $self = shift;
    print "I’m out!\n";
    $self->connection->broadcast;
}

sub registered {
    my $self = shift;
    $self->enable_ping;
    print "I’m in!\n";
}

#--------------------------------------------------------------------
# setup
#--------------------------------------------------------------------
sub _setup {
    my $self = shift;
    $self->_setup_connection;
    $self->_setup_plugins;
}

sub _setup_connection {
    my $self = shift;
    $self->condvar( AnyEvent->condvar );
    $self->connection( AnyEvent::IRC::Client->new );
    $self->_setup_hook_methods;
}

sub _setup_hook_methods {
    my $self = shift;
    foreach my $hook_method ( @{ $self->hook_methods } ) {
        $self->connection->reg_cb(
            $hook_method => sub {
                $self->$hook_method(@_);
            }
        );
    }
}

sub _setup_plugins {
    my $self = shift;
    foreach my $plugin ( @{ $self->plugins } ) {
        $self->load_plugin( $plugin->{module} );
    }
}

#--------------------------------------------------------------------
# run
#--------------------------------------------------------------------
sub run {
    my $self = shift;
    $self->connect_to_server;
    $self->connect_to_channels;
    $self->_recv;
}

sub _recv {
    my $self = shift;
    $self->condvar->recv;
}

# lifecycle hook
sub connect_to_server {
    my $self = shift;
    $self->connection->connect( $self->server, $self->port,
        { nick => $self->nick, user => $self->username, real => $self->name }
    );
}

# lifecycle hook
sub connect_to_channels {
    my $self = shift;
    foreach my $channel ( @{ $self->channels } ) {
        $self->connection->send_srv( "JOIN", $channel );
    }
}

#--------------------------------------------------------------------
# utility methods
#--------------------------------------------------------------------
sub plugin_config {
    my ( $self, $plugin_name ) = @_;
    foreach my $plugin ( @{ $self->plugins } ) {
        if ( $plugin_name eq $plugin->{module} ) {
            return $plugin->{config};
        }
    }
}

sub enable_ping {
    my $self = shift;
    $self->connection->enable_ping( $self->reconnect_period );
}

sub notice {
    my ( $self, $channel, $message ) = @_;
    $self->connection->send_chan( $channel, "NOTICE", $channel,
        encode( $self->charset, $message ) );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=encoding utf-8

=head1 NAME

Bot::IRC::Lite - AnyEvent based pluggable IRC bot

=head1 SYNOPSIS

  use Bot::IRC::Lite;
  my $bot = Bot::IRC::Lite->new(
      server => "irc.example.com",
      port   => "6667",
      channels => ["#bottest"],
      nick      => "botirclite",
      username  => "bot",
      name      => "Yet Another Bot",
      ignore_list => [qw(dipsy dadadodo laotse)],
      charset => "utf-8", # charset the bot assumes the channel is using
  );
  $bot->run();

=head1 DESCRIPTION

Bot::IRC::Lite is


=head1 SOURCE AVAILABILITY

This source is in Github:

  http://github.com/dann/

=head1 CONTRIBUTORS


=head1 AUTHOR

Takatoshi Kitano E<lt>kitano.tk@gmail.comE<gt>

=head1 SEE ALSO

L<POE::Component::IRC>

L<Bot::BasicBot>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
