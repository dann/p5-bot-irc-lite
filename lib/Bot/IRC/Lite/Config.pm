package Bot::IRC::Lite::Config;
use strict;
use warnings;
use Bot::IRC::Lite::ConfigLoader;
use Path::Class;
use base 'Class::Singleton';

sub _new_instance {
    my $class = shift;
    my $self = bless {}, $class;
    my $config_path = shift || file($ENV{HOME}, '.botirclite' );
    $self->{config} = Bot::IRC::Lite::ConfigLoader->load( $config_path);
    return $self;
}

sub global {
    my $self = shift;
    my $var  = shift;
    $self->_get( 'global', $var );
}

sub plugins {
    my $self = shift;
    return $self->{config}->{plugins} || [];
}

sub plugin {
    my $self    = shift;
    my $type    = shift;
    my $module  = shift;
    my $plugins = $self->_get( 'plugins', $type );
    unless ($plugins) {
        return wantarray ? () : [];
    }
    if ($module) {
        foreach my $plugin ( @{$plugins} ) {
            if ( $module eq $plugin->{module} ) {
                return $plugin;
            }
        }
        return;
    }
    return wantarray ? @{$plugins} : $plugins;
}


sub _get {
    my $self    = shift;
    my $section = shift;
    my $var     = shift;
    unless ( $self->{config}->{$section} ) {
        return;
    }

    unless ($var) {
        return $self->{config}->{$section};
    }
    return $self->{config}->{$section}->{$var};
}

1;
