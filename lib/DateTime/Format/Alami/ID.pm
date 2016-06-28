package DateTime::Format::Alami::ID;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

# XXX relative day reference -> yesterday | today | tomorrow (-1, 0, 1)
# XXX holidays -> christmas | new year | ...
# XXX 13.00 WIB
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
sub p_dateymd        { join(
    "",
    '(?{ $DateTime::Format::Alami::_has_year = 0 })',
    '(?: <o_dayint>(?:\s+|-|/)?<o_monthname> | <o_dayint>(?:\s+|-|/)<o_monthint>\b )',
    '(?: \s*[,/-]?\s* <o_yearint>  (?{ local $DateTime::Format::Alami::_has_year = $DateTime::Format::Alami::_has_year + 1 }))?',
    '(?{ delete $DateTime::Format::Alami::m->{o_yearint} unless $DateTime::Format::Alami::_has_year })',
)}

sub p_dur_ago        { "<o_dur> \\s+ (?:(?:(?:yang|yg) \\s+)?lalu|tadi|td|yll?)" }
sub p_dur_later      { "<o_dur> \\s+ (?:(?:(?:yang|yg) \\s+)?akan \\s+ (?:datang|dtg)|yad|lagi|lg)" }

sub o_date           { "(?: <p_today>|<p_tomorrow>|<p_yesterday>|<p_dateymd>)" }
sub p_time           { "(?: <o_hour>[:.]<o_minute>(?: [:.]<o_second>)?)" }
sub p_date_time      { "(?:<o_date> \\s+ (?:(?:pada \\s+)? (jam|j|pukul|pkl?)\\s*)? <p_time>)" }

# the ordering is a bit weird because: we need to apply role at compile-time
# before the precomputed $RE mentions $o & $m thus creating the package
# DateTime::Format::Alami and this makes Role::Tiny::With complains that DT:F:A
# is not a role. then, if we are to apply the role, we need to already declare
# the methods required by the role.

use Role::Tiny::With;
BEGIN { with 'DateTime::Format::Alami' };

our $RE   = do { DateTime::Format::Alami::ID->new; $DateTime::Format::Alami::ID::RE   }; # PRECOMPUTE
our $MAPS = do { DateTime::Format::Alami::ID->new; $DateTime::Format::Alami::ID::MAPS }; # PRECOMPUTE

1;
# ABSTRACT: Parse human date/time expression (Indonesian)

=for Pod::Coverage ^([aopw]_.+)$

=head1 DESCRIPTION

List of known date/time expressions:

 # p_now
 sekarang
 saat ini

 # p_today
 hari ini

 # p_tomorrow
 besok

 # p_yesterday
 kemarin

 # p_dur_ago, p_dur_later
 1 tahun 2 bulan 3 minggu 4 hari 5 jam 6 menit 7 detik (lalu|lagi|nanti|yang akan datang)

 # p_dateymd
 28 mei
 28/5
 28 mei 2016
 28-5-2016
 28-5-16

 # p_time
 (pukul|jam)? 10.00
 23:05:44

 # p_date_time
 24 juni pk 13.00
 24 juni 2015 13:00


=head1 SEE ALSO

L<DateTime::Format::Indonesian>

L<Date::Extract::ID>
