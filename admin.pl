#!/usr/bin/perl

use strict;

BEGIN {
  unshift @INC, "modules/override"; # Use our own versions of various modules (e.g. YAML).
  push    @INC, "modules/fallback"; # Only use our own versions of modules if there's no system version.
  push    @INC, "SL";               # FCGI won't find modules that are not properly named. Help it by inclduging SL
}

use SL::Dispatcher;

SL::Dispatcher::pre_startup();
SL::Dispatcher::handle_request('CGI');

1;
