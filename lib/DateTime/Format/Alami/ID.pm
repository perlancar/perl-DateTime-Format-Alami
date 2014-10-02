package DateTime::Format::Alami::ID;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use parent qw(DateTime::Format::Alami);

our $RE; # PRECOMPUTE

# XXX *se*minggu (instead of 1 minggu), etc

use Parse::Number::ID qw(parse_number_id);

sub o_num       { $Parse::Number::ID::Pat }
sub _parse_num  { parse_number_id(text => $_[1]) }
sub w_year      { ["tahun", "thn", "th"] }
sub w_month     { ["bulan", "bul", "bln", "bl"] }
sub w_week      { ["minggu", "mgg", "mg"] }
sub w_day       { ["hari", "hr", "h"] }
sub w_hour      { ["jam", "j"] }
sub w_minute    { ["menit", "mnt"] }
sub w_second    { ["detik", "det", "dtk", "dt"] }

sub p_now       { "(?:saat ini|sekarang|skrg?)" }
sub p_today     { "(?:hari ini)" }
sub p_tomorrow  { "(?:b?esok|bsk)" }
sub p_yesterday { "(?:kemar[ei]n|kmrn)" }
sub p_dur_ago   { "<o_dur> (?:(?:(?:yang|yg) )?lalu|tadi|td|yll?)" }
sub p_dur_later { "<o_dur> (?:(?:(?:yang|yg) )?akan (?:datang|dtg)|yad|lagi|lg)" }

1;
# ABSTRACT: Parse human date/time expression (Indonesian)
