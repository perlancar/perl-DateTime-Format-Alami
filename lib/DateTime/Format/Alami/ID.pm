package DateTime::Format::Alami::ID;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;
use parent qw(DateTime::Format::Alami);

our $RE   = do { DateTime::Format::Alami::ID->new; $DateTime::Format::Alami::ID::RE   }; # PRECOMPUTE
our $MAPS = do { DateTime::Format::Alami::ID->new; $DateTime::Format::Alami::ID::MAPS }; # PRECOMPUTE

# XXX relative day reference -> yesterday | today | tomorrow (-1, 0, 1)
# XXX holidays -> christmas | new year | ...

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

sub w_jan       { ["januari", "jan"] }
sub w_feb       { ["februari", "pebruari", "feb", "peb"] }
sub w_mar       { ["maret", "mar"] }
sub w_apr       { ["april", "apr"] }
sub w_may       { ["mei"] }
sub w_jun       { ["juni", "jun"] }
sub w_jul       { ["juli", "jul"] }
sub w_aug       { ["agustus", "agu", "agt"] }
sub w_sep       { ["september", "sept", "sep"] }
sub w_oct       { ["oktober", "okt"] }
sub w_nov       { ["november", "nopember", "nov", "nop"] }
sub w_dec       { ["desember", "des"] }

sub p_now            { "(?:saat \\s+ ini|sekarang|skrg?)" }
sub p_today          { "(?:hari \\s+ ini)" }
sub p_tomorrow       { "(?:b?esok|bsk)" }
sub p_yesterday      { "(?:kemar[ei]n|kmrn)" }
sub p_date_ymd       { "(?: <o_dayint>(?:\\s+|-|/)?<o_monthname> | <o_dayint>(?:\\s+|-|/)<o_monthint>\\b )(?: \\s*[,/-]?\\s* <o_yearint>)?" }
sub p_dur_ago        { "<o_dur> \\s+ (?:(?:(?:yang|yg) \\s+)?lalu|tadi|td|yll?)" }
sub p_dur_later      { "<o_dur> \\s+ (?:(?:(?:yang|yg) \\s+)?akan \\s+ (?:datang|dtg)|yad|lagi|lg)" }

1;
# ABSTRACT: Parse human date/time expression (Indonesian)

=for Pod::Coverage ^([aopw]_.+)$

=head1 DESCRIPTION

List of known date/time expressions:

 sekarang|saat ini
 hari ini
 besok
 kemarin
 1 tahun 2 bulan 3 minggu 4 hari 5 jam 6 menit 7 detik (lalu|nanti|yang akan datang)
 28 mei, 28/5
 28 mei 2016

List of recognized duration expressions:
