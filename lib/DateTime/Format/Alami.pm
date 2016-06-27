package DateTime::Format::Alami;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::Any::IfLOG '$log';

use Role::Tiny;

my @short_mons = qw(jan feb mar apr may jun jul aug sep oct nov dec);

requires 'o_num';
requires '_parse_num';

requires 'w_year';
requires 'w_month';
requires 'w_week';
requires 'w_day';
requires 'w_hour';
requires 'w_minute';
requires 'w_second';

requires "w_$_" for @short_mons;

requires 'p_now';
requires 'p_today';
requires 'p_yesterday';
requires 'p_tomorrow';
requires 'p_dateymd';
requires 'o_date';
requires 'p_dur_ago';
requires 'p_dur_later';
requires 'p_time';
requires 'p_date_time';

our ($m, $o);
sub new {
    my $class = shift;
    if ($class eq __PACKAGE__) {
        die "Use one of the DateTime::Format::Alami::* instead, ".
            "e.g. DateTime::Format::Alami::EN";
    }
    my $self = bless {}, $class;
    no strict 'refs';
    unless (${"$class\::RE"}) {
        require Class::Inspector;
        my $meths = Class::Inspector->methods($class);
        my %pats;  # key = "p_..."
        my %pat_lengths; # key = "p_..."
        for my $meth (@$meths) {
            next unless $meth =~ /^[op]_/;
            my $pat = $self->$meth;
            $pat =~ s/<(\w+)>/(?\&$1)/g;
            my $action_meth = $meth; $action_meth =~ s/^p_/a_/;
            $pat = join(
                "",
                "(", ($meth =~ /^p_/ ? "\\b $pat \\b" : $pat), ")",

                # we capture ourselves instead of relying on named capture
                # because subpattern capture are discarded
                "(?{ \$DateTime::Format::Alami::m->{$meth} = \$^N })",

                ($meth =~ /^p_/ ? "(?{ ".($ENV{DEBUG} ? "say \"invoking $action_meth()\";" : "")."\$DateTime::Format::Alami::o->{_pat} = \"$meth\"; \$DateTime::Format::Alami::o->$action_meth(\$DateTime::Format::Alami::m) })" : ""),
            );
            $pats{$meth}  = $pat;
            $pat_lengths{$meth} = length($pat);
        }
        my @pat_names =
            sort { $pat_lengths{$b} <=> $pat_lengths{$a} } keys %pats;
        my $nl = $ENV{DEBUG} ? "\n" : "";
        my $re = join(
            "",
            "(?&top)", $nl,
            #"(?&p_dateymd)", $nl, # testing
            "(?(DEFINE)", $nl,
            "(?<top>", join("|",
                            map {"(?&$_)"} grep {/^p_/} @pat_names), ")$nl",
            (map { "(?<$_> $pats{$_})$nl" } @pat_names),
            ")", # end of define
        );
        {
            use re 'eval';
            ${"$class\::RE"} = qr/$re/ix;
        }
    }
    unless (${"$class\::MAPS"}) {
        my $maps = {};
        # month names -> num
        {
            my $i = 0;
            for my $m (@short_mons) {
                ++$i;
                my $meth = "w_$m";
                for (@{ $self->$meth }) {
                    $maps->{months}{$_} = $i;
                }
            }
        }
        ${"$class\::MAPS"} = $maps;
    }
    $self;
}

sub _reset {
    my $self = shift;
    undef $self->{_pat};
    undef $self->{_dt};
    undef $self->{_uses_time};
}

sub parse_datetime {
    require DateTime;
    no strict 'refs';

    my ($self, $str, $opts) = @_;

    $opts //= {};
    $opts->{format} //= 'DateTime';
    #$opts->{prefers} //= 'nearest';
    $opts->{returns} //= 'first';

    local $self->{_time_zone} = $opts->{time_zone} if $opts->{time_zone};

    my $re = ${ref($self).'::RE'};

    $o = $self;
    my @res;
    while (1) {
        $o->_reset;
        $m = {};
        $str =~ /($re)/go or last;
        $o->{_dt}->truncate(to=>'day') unless $o->{_uses_time};
        my $res = {
            verbatim => $1,
            pattern => $o->{_pat},
            pos => pos($str) - length($1),
            m => {%$m},
        };
        $res->{uses_time} = $o->{_uses_time} ? 1:0;
        $res->{DateTime}  = $o->{_dt};
        $res->{epoch}     = $o->{_dt}->epoch if
            $opts->{format} eq 'combined' || $opts->{format} eq 'epoch';
        push @res, $res;
        last if $opts->{returns} eq 'first';
    }

    return undef unless @res;

    @res = ($res[-1]) if $opts->{returns} eq 'last';

    if ($opts->{returns} =~ /\A(?:all_cron|earliest|latest)\z/) {
        # sort chronologically, note that by this time the DateTime module
        # should already have been loaded
        @res = sort {
            DateTime->compare($a->{DateTime}, $b->{DateTime})
        } @res;
    }

    if ($opts->{format} eq 'DateTime') {
        @res = map { $_->{DateTime} } @res;
    } elsif ($opts->{format} eq 'epoch') {
        @res = map { $_->{epoch} } @res;
    } elsif ($opts->{format} eq 'verbatim') {
        @res = map { $_->{verbatim} } @res;
    }

    if ($opts->{returns} =~ /\A(?:all|all_cron)\z/) {
        return \@res;
    } elsif ($opts->{returns} =~ /\A(?:first|earliest)\z/) {
        return $res[0];
    } elsif ($opts->{returns} =~ /\A(?:last|latest)\z/) {
        return $res[-1];
    } else {
        die "Unknown returns option '$opts->{returns}'";
    }
}

sub o_dayint { "(?:[12][0-9]|3[01]|0?[1-9])" }

sub o_monthint { "(?:0?[1-9]|1[012])" }

sub o_yearint { "(?:[0-9]{4}|[0-9]{2})" }

sub o_hour { "(?:[0-9][0-9]?)" }

sub o_minute { "(?:[0-9][0-9]?)" }

sub o_second { "(?:[0-9][0-9]?)" }

sub o_monthname {
    my $self = shift;
    "(?:" . join(
        "|",
        (map {my $meth="w_$_"; @{ $self->$meth }} @short_mons)
    ) . ")";
}

sub o_durwords  {
    my $self = shift;
    "(?:" . join(
        "|",
        @{ $self->w_year }, @{ $self->w_month }, @{ $self->w_week },
        @{ $self->w_day },
        @{ $self->w_hour }, @{ $self->w_minute }, @{ $self->w_second },
    ) . ")";
}

sub o_dur {
    my $self = shift;
    "(?:(" . $self->o_num . "\\s*" . $self->o_durwords . "\\s*)+)";
}

# durations less than a day
sub o_timedurwords  {
    my $self = shift;
    "(?:" . join(
        "|",
        @{ $self->w_hour }, @{ $self->w_minute }, @{ $self->w_second },
    ) . ")";
}

sub o_timedur {
    my $self = shift;
    "(?:(" . $self->o_num . "\\s*?" . $self->o_timedurwords . "\\s*)+)";
}

sub _parse_dur {
    use experimental 'smartmatch';

    my ($self, $str) = @_;

    #say "D:dur=$str";
    my %args;
    unless ($self->{_cache_re_parse_dur}) {
        my $o_num = $self->o_num;
        my $o_dw  = $self->o_durwords;
        $self->{_cache_re_parse_dur} = qr/($o_num)\s*($o_dw)/ix;
    }
    unless ($self->{_cache_w_second}) {
        $self->{_cache_w_second} = $self->w_second;
        $self->{_cache_w_minute} = $self->w_minute;
        $self->{_cache_w_hour}   = $self->w_hour;
        $self->{_cache_w_day}    = $self->w_day;
        $self->{_cache_w_week}   = $self->w_week;
        $self->{_cache_w_month}  = $self->w_month;
        $self->{_cache_w_year}   = $self->w_year;
    }
    while ($str =~ /$self->{_cache_re_parse_dur}/g) {
        my ($n, $unit) = ($1, $2);
        $n = $self->_parse_num($n);
        if ($unit ~~ $self->{_cache_w_second}) {
            $args{seconds} = $n;
            $self->{_uses_time} = 1;
        } elsif ($unit ~~ $self->{_cache_w_minute}) {
            $args{minutes} = $n;
            $self->{_uses_time} = 1;
        } elsif ($unit ~~ $self->{_cache_w_hour}) {
            $args{hours} = $n;
            $self->{_uses_time} = 1;
        } elsif ($unit ~~ $self->{_cache_w_day}) {
            $args{days} = $n;
        } elsif ($unit ~~ $self->{_cache_w_week}) {
            $args{weeks} = $n;
        } elsif ($unit ~~ $self->{_cache_w_month}) {
            $args{months} = $n;
        } elsif ($unit ~~ $self->{_cache_w_year}) {
            $args{years} = $n;
        }
    }
    require DateTime::Duration;
    DateTime::Duration->new(%args);
}

sub _now_if_unset {
    my $self = shift;
    $self->a_now unless $self->{_dt};
}

sub _today_if_unset {
    my $self = shift;
    $self->a_today unless $self->{_dt};
}

sub a_now {
    my $self = shift;
    $self->{_dt} = DateTime->now(
        (time_zone => $self->{_time_zone}) x !!defined($self->{_time_zone}),
    );
    $self->{_uses_time} = 1;
}

sub a_today {
    my $self = shift;
    $self->{_dt} = DateTime->today(
        (time_zone => $self->{_time_zone}) x !!defined($self->{_time_zone}),
    );
    $self->{_uses_time} = 0;
}

sub a_yesterday {
    my $self = shift;
    $self->a_today;
    $self->{_dt}->subtract(days => 1);
}

sub a_tomorrow {
    my $self = shift;
    $self->a_today;
    $self->{_dt}->add(days => 1);
}

sub a_dateymd {
    my ($self, $m) = @_;
    $self->a_today;
    if (defined $m->{o_yearint}) {
        my $year;
        if (length($m->{o_yearint}) == 2) {
            my $start_of_century_year = int($self->{_dt}->year / 100) * 100;
            $year = $start_of_century_year + $m->{o_yearint};
        } else {
            $year = $m->{o_yearint};
        }
        $self->{_dt}->set_year($year);
    }
    if (defined $m->{o_dayint}) {
        $self->{_dt}->set_day($m->{o_dayint});
    }
    if (defined $m->{o_monthint}) {
        $self->{_dt}->set_month($m->{o_monthint});
    }
    if (defined $m->{o_monthname}) {
        no strict 'refs';
        my $maps = ${ ref($self) . '::MAPS' };
        $self->{_dt}->set_month($maps->{months}{lc $m->{o_monthname}});
    }
}

sub a_dur_ago {
    my ($self, $m) = @_;
    $self->a_now;
    my $dur = $self->_parse_dur($m->{o_dur});
    $self->{_dt}->subtract_duration($dur);
}

sub a_dur_later {
    my ($self, $m) = @_;
    $self->a_now;
    my $dur = $self->_parse_dur($m->{o_dur});
    $self->{_dt}->add_duration($dur);
}

sub a_time {
    my ($self, $m) = @_;
    $self->_now_if_unset;
    $self->{_uses_time} = 1;
    $self->{_dt}->set_hour($m->{o_hour});
    $self->{_dt}->set_minute($m->{o_minute});
    $self->{_dt}->set_second($m->{o_second}) if defined $m->{o_second};
}

sub a_date_time {
    my ($self, $m) = @_;
}

1;
# ABSTRACT: Parse human date/time expression (base class)

=for Pod::Coverage ^([aopw]_.+)$

=head1 SYNOPSIS

Use English:

 use DateTime::Format::Alami::EN;
 my $parser = DateTime::Format::Alami::EN->new();
 my $dt;
 $dt = $parser->parse_datetime("2 hours 13 minutes from now");
 $dt = $parser->parse_datetime("yesterday");

use Indonesian:

 use DateTime::Format::Alami::ID;
 my $parser = DateTime::Format::Alami::ID->new();
 my $dt;
 $dt = $parser->parse_datetime("5 jam lagi");
 $dt = $parser->parse_datetime("hari ini");


=head1 DESCRIPTION

This class parses human/natural date/time string and returns DateTime object.
Currently it supports English and Indonesian. The goal of this module is to make
it easier to add support for other human languages.

To actually use this class, you must use one of its subclasses for each
human language that you want to parse.

There are already some other DateTime human language parsers on CPAN and
elsewhere, see L</"SEE ALSO">.


=head1 HOW IT WORKS

L<DateTime::Format::Alami> is base class. Each human language is implemented in
a separate C<< DateTime::Format::Alami::<ISO_CODE> >> module (e.g.
L<DateTime::Format::Alami::EN> and L<DateTime::Format::Alami::EN>) which is a
subclass.

Parsing is done using a single recursive regex (i.e. containing C<(?&NAME)> and
C<(?(DEFINE))> patterns, see L<perlre>). This regex is composed from pieces of
pattern strings in the C<p_*> and C<o_*> methods, to make it easier to override
in an OO-fashion.

A pattern string that is returned by the C<p_*> method is a normal regex pattern
string that will be compiled using the /x and /i regex modifier. The pattern
string can also refer to pattern in other C<o_*> or C<p_*> method using syntax
C<< <o_foo> >> or C<< <p_foo> >>. Example, C<o_today> for English might be
something like:

 sub p_today { "(?: today | this \s+ day )" }

Other examples:

 sub p_yesterday { "(?: yesterday )" }

 sub p_dateymd { join(
     "",
    '(?: <o_dayint> \\s* ?<o_monthname> | <o_monthname> \\s* <o_dayint>\\b|<o_monthint>[ /-]<o_dayint>\\b )',
    '(?: \\s*[,/-]?\\s* <o_yearint>)?'
 )}

 sub o_date { "(?: <p_today>|<p_yesterday>|<p_dateymd>)" }

 sub p_time { "(?: <o_hour>:<o_minute>(?:<o_second>)? \s* <o_ampm> )" }

 sub p_date_time { "(?: <o_date> (?:\s+ at)? <o_time> )" }

When a pattern from C<p_*> matches, a corresponding action method C<a_*> will be
invoked. Usually the method will set or modify a DateTime object in C<<
$self->{_dt} >>. For example, this is code for C<a_today>:

 sub a_today {
     my $self = shift;
     $self->{_dt} = DateTime->today;
 }

The patterns from all C<p_*> methods will be combined in an alternation to form
the final pattern.

An C<o_*> pattern is just like C<p_*>, but they will not be
combined into the final pattern and matching it won't execute a corresponding
C<a_*> method.

And there are also C<w_*> methods which return array of strings.


=head1 ADDING A NEW HUMAN LANGUAGE

TBD


=head1 METHODS

=head2 new => obj

Constructor. You actually must instantiate subclass instead.

=head2 parse_datetime($str[ , \%opts ]) => obj

Parse/extract date/time expression in C<$str>. Return undef if expression cannot
be parsed. Otherwise return L<DateTime> object (or string/number if C<format>
option is C<verbatim>/C<epoch>, or hash if C<format> option is C<combined>) or
array of objects/strings/numbers (if C<returns> option is C<all>/C<all_cron>).

Known options:

=over

=item * time_zone => str

Will be passed to DateTime constructor.

=item * format => str (DateTime|verbatim|epoch|combined)

The default is C<DateTime>, which will return DateTime object. Other choices
include C<verbatim> (returns the original text), C<epoch> (returns Unix
timestamp), C<combined> (returns a hash containing keys like C<DateTime>,
C<verbatim>, C<epoch>, and other extra information: C<pos> [position of pattern
in the string], C<pattern> [pattern name], C<m> [raw named capture groups],
C<uses_time> [whether the date involves time of day]).

You might think that choosing C<epoch> could avoid the overhead of DateTime, but
actually you can't since DateTime is used as the primary format during parsing.
The epoch is retrieved from the DateTime object using the C<epoch> method.

But if you choose C<verbatim>, you I<can> avoid the overhead of DateTime (as
long as you set C<returns> to C<first>, C<last>, or C<all>).

=item * prefers => str (nearest|future|past)

NOT YET IMPLEMENTED.

This option decides what happens when an ambiguous date appears in the input.
For example, "Friday" may refer to any number of Fridays. Possible choices are:
C<nearest> (prefer the nearest date, the default), C<future> (prefer the closest
future date), C<past> (prefer the closest past date).

=item * returns => str (first|last|earliest|latest|all|all_cron)

If the text has multiple possible dates, then this argument determines which
date will be returned. Possible choices are: C<first> (return the first date
found in the string, the default), C<last> (return the final date found in the
string), C<earliest> (return the date found in the string that chronologically
precedes any other date in the string), C<latest> (return the date found in the
string that chronologically follows any other date in the string), C<all>
(return all dates found in the string, in the order they were found in the
string), C<all_cron> (return all dates found in the string, in chronological
order).

When C<all> or C<all_cron> is chosen, function will return array(ref) of results
instead of a single result, even if there is only a single actual result.

=back


=head1 FAQ

=head2 What does "alami" mean?

It is an Indonesian word, meaning "natural".


=head1 SEE ALSO

=head2 Similar modules on CPAN

L<Date::Extract>. DateTime::Format::Alami has some features of Date::Extract so
it can be used to replace Date::Extract.

For Indonesian: L<DateTime::Format::Indonesian>, L<Date::Extract::ID> (currently
this module uses DateTime::Format::Alami as its backend).

For English: L<DateTime::Format::Natural>. You probably want to use this
instead, unless you want something other than English. I did try to create an
Indonesian translation for this module a few years ago, but gave up. Perhaps I
should make another attempt.

=head2 Other modules on CPAN

L<DateTime::Format::Human> deals with formatting and not parsing.

=head2 Similar non-Perl libraries

Natt Java library, which the last time I tried sometimes gives weird answer,
e.g. "32 Oct" becomes 1 Oct in the far future. http://natty.joestelmach.com/

Duckling Clojure library, which can parse date/time as well as numbers with some
other units like temperature. https://github.com/wit-ai/duckling

=cut
