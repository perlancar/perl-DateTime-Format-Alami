package Test::DateTime::Format::Alami;

use 5.010001;
use strict;
use warnings;

use DateTime;
use Test::More 0.98;

use Exporter qw(import);
our @EXPORT = qw(test_datetime_format_alami);

sub test_datetime_format_alami {
    my ($class0, $tests) = @_;

    my $class = "DateTime::Format::Alami::$class0";
    eval "use $class"; die if $@;

    subtest "test suite for $class" => sub {
        my $parser = $class->new;

        for my $t (@{ $tests->{parse_tests} }) {
            my ($str, $exp_template) = @$t;
            subtest $str => sub {
                my $dt = $parser->parse_datetime($str);
                if ($exp_template) {
                    ok($dt, "parse should succeed") or return;
                } else {
                    ok(!$dt, "parse should fail");
                    return;
                }

                my $now = DateTime->now;
                my $tomorrow  = $now->clone->add(days => 1);
                my $yesterday = $now->clone->subtract(days => 1);
                my $template_vars = {
                    CUR_YEAR   => $now->year,
                    CUR_MONTH  => sprintf("%02d", $now->month),
                    CUR_DAY    => sprintf("%02d", $now->day),
                    CUR_HOUR   => sprintf("%02d", $now->hour),
                    CUR_MINUTE => sprintf("%02d", $now->minute),
                    CUR_SECOND => sprintf("%02d", $now->second),

                    YEAR_TOMORROW    => $tomorrow->year,
                    MONTH_TOMORROW   => sprintf("%02d", $tomorrow->month),
                    DAY_TOMORROW     => sprintf("%02d", $tomorrow->day),
                    HOUR_TOMORROW    => sprintf("%02d", $tomorrow->hour),
                    MINUTE_TOMORROW  => sprintf("%02d", $tomorrow->minute),
                    SECOND_TOMORROW  => sprintf("%02d", $tomorrow->second),

                    YEAR_YESTERDAY   => $yesterday->year,
                    MONTH_YESTERDAY  => sprintf("%02d", $yesterday->month),
                    DAY_YESTERDAY    => sprintf("%02d", $yesterday->day),
                    HOUR_YESTERDAY   => sprintf("%02d", $yesterday->hour),
                    MINUTE_YESTERDAY => sprintf("%02d", $yesterday->minute),
                    SECOND_YESTERDAY => sprintf("%02d", $yesterday->second),
                };

                my $exp = $exp_template;
                $exp =~ s/<(\w+)>/$template_vars->{$1}/eg;
                my $dt_str;
                if ($exp =~ /T/) {
                    $dt_str = "$dt";
                } else {
                    $dt_str = $dt->ymd;
                }
                is($dt_str, $exp, "result should be $exp");
            };
        }
    };
}

1;
# ABSTRACT: Test DateTime::Format::Alami

=head1 FUNCTIONS

=head2 test_datetime_format_alami($class, \%tests)
