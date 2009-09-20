use inc::Module::Install;
name 'Bot-IRC-Lite';
all_from 'lib/Bot/IRC/Lite.pm';
{
    no warnings 'redefine';
    *recommends_hack
        = $Module::Install::VERSION > 0.70
        ? sub { recommends(@_); $_[0] }
        : \&recommends;
}

requires(
    'Mouse'                     => 0,
    'MouseX::Object::Pluggable' => 0,
    'AnyEvent'                  => 0,
    'AnyEvent::IRC::Client'     => 0,
    'Carp'                      => 0,
    'YAML'                      => 0,
    'Path::Class'               => 0,
    'Class::Singleton'          => 0,
    'Encode'                    => 0,
    'FindBin::libs'             => 0,
);

features(
    'use RSS plugin?' => [
        -default => 0,
        recommends_hack( 'AnyEvent::Feed' => 0 ),
    ],
);

test_requires(
    'Test::More'           => 0,
    'Test::LoadAllModules' => 0,
    'Test::Requires'       => 0,
);

use_test_base;
auto_include;
WriteAll;