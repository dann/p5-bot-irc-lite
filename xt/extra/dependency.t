use Test::Dependencies
    exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic Bot::IRC::Lite/],
    style   => 'light';
ok_dependencies();
