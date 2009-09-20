package Bot::IRC::Lite::ConfigLoader;
use strict;
use Carp;
use YAML;

sub load {
    my ( $self, $stuff ) = @_;
    my $config;
    if (   ( !ref($stuff) && $stuff eq '-' )
        || ( -e $stuff && -r _ ) )
    {
        $config = YAML::LoadFile($stuff);
    }
    elsif ( ref($stuff) && ref($stuff) eq 'SCALAR' ) {
        $config = YAML::Load( ${$stuff} );
    }
    elsif ( ref($stuff) && ref($stuff) eq 'HASH' ) {
        $config
            = $stuff->{global}->{no_config_clone}
            ? $stuff
            : Storable::dclone($stuff);
    }
    else {
        croak "Bot::IRC::Lite::ConfigLoader->load: $stuff: $!";
    }
    return $config;
}

1;
