package Bot::IRC::Lite::Script;
use Mouse;
use Pod::Usage;
use Bot::IRC::Lite;
use Bot::IRC::Lite::Config;

with 'MouseX::Getopt';

has 'help' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has 'conf' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub run {
    my $self = shift;
    if ( $self->help ) {
        pod2usage(2);
    }
    die 'conf is required param' unless $self->conf;

    my $config = $self->load_config( $self->conf );

    my $bot    = Bot::IRC::Lite->new(
        server      => $config->global('server'),
        port        => $config->global('port'),
        channels    => $config->global('channels'),
        nick        => $config->global('nick'),
        username    => $config->global('username'),
        name        => $config->global('name'),
        ignore_list => $config->global('ignore_list'),
        charset     => $config->global('charset'),
        plugins     => $config->plugins,
    );
    $bot->run;
}

sub load_config {
    my $self   = shift;
    my $config = Bot::IRC::Lite::Config->instance( $self->conf );
    $config;
}

no Mouse;
__PACKAGE__->meta->make_immutable;
1;

