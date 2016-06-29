package DateTime::Format::Alami::EN;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

# XXX holidays -> christmas | new year | ...
# XXX timezone in time
# XXX more patterns from DT:F:Natural

use Parse::Number::EN qw(parse_number_en);

sub o_num       { $Parse::Number::EN::Pat }
sub _parse_num  { parse_number_en(text => $_[1]) }
sub w_year      { ["year", "years", "y"] }
sub w_month     { ["month", "months", "mon"] }
sub w_week      { ["week", "weeks", "wk", "wks"] }
sub w_day       { ["day", "days", "d"] }
sub w_hour      { ["hour", "hours", "h"] }
sub w_minute    { ["minute", "minutes", "min", "mins"] }
sub w_second    { ["second", "seconds", "sec", "secs", "s"] }

sub w_jan       { ["january", "jan"] }
sub w_feb       { ["february", "feb"] }
sub w_mar       { ["march", "mar"] }
sub w_apr       { ["april", "apr"] }
sub w_may       { ["may"] }
sub w_jun       { ["june", "jun"] }
sub w_jul       { ["july", "jul"] }
sub w_aug       { ["august", "aug"] }
sub w_sep       { ["september", "sept", "sep"] }
sub w_oct       { ["october", "oct"] }
sub w_nov       { ["november", "nov"] }
sub w_dec       { ["december", "dec"] }

sub p_now          { "(?:(?:(?:right|just) \\s+ )?now|immediately)" }
sub p_today        { "(?:today|this \\s+ day)" }
sub p_tomorrow     { "(?:tomorrow|tom)" }
sub p_yesterday    { "(?:yesterday|yest)" }
# XXX support cardinal
sub p_dateymd      { join(
    # we use the 'local' trick here in embedded code (see perlre) to be
    # backtrack-safe. we want to unset $m->{o_yearint} when date does not
    # contain year. $m->{o_yearint} might be set when we try the patterns but
    # might end up needing to be unset if the matching pattern ends up not
    # having year.
    "",
    '(?{ $DateTime::Format::Alami::_has_year = 0 })',
    '(?: <o_dayint> \\s* <o_monthname> | <o_monthname> \\s* <o_dayint>\\b|<o_monthint>[ /-]<o_dayint>\\b )',
    '(?: \\s*[,/-]?\\s* <o_yearint> (?{ local $DateTime::Format::Alami::_has_year = $DateTime::Format::Alami::_has_year + 1 }))?',
    '(?{ delete $DateTime::Format::Alami::m->{o_yearint} unless $DateTime::Format::Alami::_has_year })',
)}

sub p_dur_ago      { "<o_dur> \\s+ (?:ago)" }
sub p_dur_later    { "<o_dur> \\s+ (?:later)" }

sub o_date         { "(?: <p_today>|<p_tomorrow>|<p_yesterday>|<p_dateymd>)" }
sub o_ampm         { "(?: am|pm)" }
sub p_time         { "(?: <o_hour>[:.]<o_minute>(?: [:.]<o_second>)? \\s* <o_ampm>?)" } # XXX am/pm
sub p_date_time    { "(?:<o_date> \\s+ (?:(?:on|at) \\s+)? <p_time>)" }

# the ordering is a bit weird because: we need to apply role at compile-time
# before the precomputed $RE mentions $o & $m thus creating the package
# DateTime::Format::Alami and this makes Role::Tiny::With complains that DT:F:A
# is not a role. then, if we are to apply the role, we need to already declare
# the methods required by the role.

use Role::Tiny::With;
BEGIN { with 'DateTime::Format::Alami' };

our $RE_DT  = do { DateTime::Format::Alami::EN->new; $DateTime::Format::Alami::EN::RE_DT  }; # PRECOMPUTE
our $RE_DUR = do { DateTime::Format::Alami::EN->new; $DateTime::Format::Alami::EN::RE_DUR }; # PRECOMPUTE
our $MAPS   = do { DateTime::Format::Alami::EN->new; $DateTime::Format::Alami::EN::MAPS   }; # PRECOMPUTE

1;
# ABSTRACT: Parse human date/time/duration expression (English)

=for Pod::Coverage ^((adur|a|pdur|p|odur|o|w)_.+)$

=head1 DESCRIPTION

List of known date/time expressions:

 # p_now
 (just|right)? now

 # p_today
 today|this day

 # p_tomorrow
 tommorow

 # p_yesterday
 yesterday

 # p_dur_ago, p_dur_later
 1 year 2 months 3 weeks 4 days 5 hours 6 minutes 7 seconds (ago|later)

 # p_dateymd
 may 28
 5/28
 28 may 2016
 may 28, 2016
 5/28/2016
 5-28-16

 # p_time
 2pm
 3.45 am
 (on|at)? 15:00

 # p_date_time
 june 25 2pm
 2016-06-25 10:00:00

List of known duration expressions:

 # pdur_dur
 1 year 2 months 3 weeks 4 days 5 hours 6 minutes 7 seconds


=head1 SEE ALSO

L<DateTime::Format::Natural>
