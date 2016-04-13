package DateTime::Format::Alami::EN;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;
use parent qw(DateTime::Format::Alami);

our $RE   = do { DateTime::Format::Alami::EN->new; $DateTime::Format::Alami::EN::RE   }; # PRECOMPUTE
our $MAPS = do { DateTime::Format::Alami::EN->new; $DateTime::Format::Alami::EN::MAPS }; # PRECOMPUTE

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
sub p_date_ymd     { join(
    "",
    '(?: <o_dayint> \\s* ?<o_monthname> | <o_monthname> \\s* <o_dayint>\\b|<o_monthint>[ /-]<o_dayint>\\b )',
    '(?: \\s*[,/-]?\\s* <o_yearint>)?'
)}
sub p_dur_ago      { "<o_dur> \\s+ (?:ago)" }
sub p_dur_later    { "<o_dur> \\s+ (?:later)" }

1;
# ABSTRACT: Parse human date/time expression (English)

=for Pod::Coverage ^([aopw]_.+)$

=head1 DESCRIPTION

List of known date/time expressions:

 (just|right)? now

 today|this day
 tommorow
 yesterday

 1 year 2 months 3 weeks 4 days 5 hours 6 minutes 7 seconds (ago|later)

 may 28
 5/28

 28 may 2016
 may 28, 2016
 5/28/2016
 5-28-16

List of recognized duration expressions:
