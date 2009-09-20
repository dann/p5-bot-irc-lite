#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;
use Bot::IRC::Lite::Script;

my $script = Bot::IRC::Lite::Script->new_with_options;
$script->run;

