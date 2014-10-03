package DateTime::Format::Alami;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use experimental 'smartmatch';

my @shortmons = qw(jan feb mar apr may jun jul aug sep oct nov dec);

# must be overriden
sub o_num       {}
sub _parse_num  {}
sub w_year   {}
sub w_month  {}
sub w_week   {}
sub w_day    {}
sub w_minute {}
sub w_second {}
sub p_now       {}
sub p_today     {}
sub p_tomorrow  {}
sub p_yesterday {}
sub p_dur_ago   {}
sub p_dur_later {}

sub new {
    my $class = shift;
    if ($class eq __PACKAGE__) {
        die "Use one of my subclasses instead, ".
            "e.g. DateTime::Format::Alami::EN";
    }
    my $self = bless {}, $class;
    no strict 'refs';
    unless (${"$class\::RE"}) {
        require Class::Inspector;
        my $meths = Class::Inspector->methods($class);
        my @pats;
        for (@$meths) {
            next unless /^p_/;
            my $pat = $self->$_;
            $pat =~ s/<(\w+)>/"(?P<$1>" . $self->$1 . ")"/eg;
            push @pats, "(?P<$_>$pat)";
        }
        ${"$class\::RE"} = join("|", sort {length($b)<=>length($a)} @pats);
    }
    unless (${"$class\::MAPS"}) {
        my $maps = {};
        # month names -> num
        {
            my $i = 0;
            for my $m (@shortmons) {
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

sub parse_datetime {
    my ($self, $str) = @_;

    undef $self->{_dt};
    no strict 'refs';
    $str =~ /${ ref($self) . '::RE' }/o or return undef;
    my %m = %+;
    for (keys %m) {
        if (/^p_(.+)/) {
            my $meth = "a_$1";
            $self->$meth(\%m);
            last;
        }
    }
    $self->{_dt};
}

sub o_dayint { "(?:[12][0-9]|3[01]|0?[1-9])" }

sub o_monthint { "(?:0?[1-9]|1[012])" }

sub o_monthname {
    my $self = shift;
    "(?:" . join(
        "|",
        (map {my $meth="w_$_"; @{ $self->$meth }} @shortmons)
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
    "(?:(" . $self->o_num . " ?" . $self->o_durwords . " ?)+)";
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
    "(?:(" . $self->o_num . " ?" . $self->o_timedurwords . " ?)+)";
}

sub _parse_dur {
    my ($self, $str) = @_;

    my %args;
    unless ($self->{_cache_re_parse_dur}) {
        my $o_num = $self->o_num;
        my $o_dw  = $self->o_durwords;
        $self->{_cache_re_parse_dur} = qr/($o_num) ?($o_dw)/;
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
        } elsif ($unit ~~ $self->{_cache_w_minute}) {
            $args{minutes} = $n;
        } elsif ($unit ~~ $self->{_cache_w_hour}) {
            $args{hours} = $n;
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
    DateTime::Duration->new(%args);
}

sub _setif_now {
    my $self = shift;
    unless ($self->{_dt}) {
        require DateTime;
        $self->{_dt} = DateTime->now;
    }
}

sub _setif_today {
    my $self = shift;
    unless ($self->{_dt}) {
        require DateTime;
        $self->{_dt} = DateTime->today;
    }
}

sub a_now {
    my $self = shift;
    $self->_setif_now;
}

sub a_today {
    my $self = shift;
    $self->_setif_today;
}

sub a_timedur_today {
    my $self = shift;
    $self->_setif_today;
}

sub a_yesterday {
    my $self = shift;
    $self->_setif_today;
    $self->{_dt}->subtract(days => 1);
}

sub a_date_wo_year {
    my ($self, $m) = @_;
    $self->_setif_now;
    if (defined $m->{o_monthint}) {
        $self->{_dt}->set_month($m->{o_monthint});
    }
    if (defined $m->{o_monthname}) {
        no strict 'refs';
        my $maps = ${ ref($self) . '::MAPS' };
        $self->{_dt}->set_month($maps->{months}{$m->{o_monthname}});
    }
    if (defined $m->{o_dayint}) {
        $self->{_dt}->set_day($m->{o_dayint});
    }
}

sub a_dur_ago {
    my ($self, $m) = @_;
    $self->_setif_now;
    my $dur = $self->_parse_dur($m->{o_dur});
    $self->{_dt}->subtract_duration($dur);
}

sub a_dur_later {
    my ($self, $m) = @_;
    $self->_setif_now;
    my $dur = $self->_parse_dur($m->{o_dur});
    $self->{_dt}->add_duration($dur);
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

B<EARLY RELEASE: PROOF OF CONCEPT ONLY AND VERY VERY INCOMPLETE.>

This class parses human/natural date/time string and returns DateTime object.
Currently it supports English and Indonesian. It is meant to be simple to
add support for other human languages.

It works by matching date string with a bunch of regex patterns (assembled from
C<p_*> methods, e.g. C<p_today>, C<p_dur_ago>, C<p_dur_later>, and so on). If a
pattern is found, the corresponding C<a_*> method is called to compute the
DateTime object (e.g. if C<p_today> pattern matches, C<a_today> is called).

To actually use this class, you must use one of its subclasses for each
human language that you want to parse.

There are already some other DateTime human language parsers on CPAN and
elsewhere, see L</"SEE ALSO">.


=head1 ADDING A NEW HUMAN LANGUAGE

TBD


=head1 METHODS

=head2 new => obj

Constructor. You actually must instantiate subclass instead.

=head2 parse_datetime($str) => obj

Parse date/time expression in C<$str> and return L<DateTime> object. Return
undef if expression cannot be parsed.


=head1 FAQ

=head2 What does "alami" mean?

It is an Indonesian word, meaning "natural".


=head1 SEE ALSO

=head2 Similar modules on CPAN

L<DateTime::Format::Natural>. Translating to a language other than English looks
very complex. This is indicated by the lack of support for non-English
languages.

=head2 Other modules on CPAN

L<DateTime::Format::Human> deals with formatting and not parsing.

=head2 Similar non-Perl libraries

Natt Java library, which the last time I tried sometimes gives weird answer,
e.g. "32 Oct" becomes 1 Oct in the far future. http://natty.joestelmach.com/

Duckling Clojure library, which can parse date/time as well as numbers with some
other units like temperature. https://github.com/wit-ai/duckling

=cut
