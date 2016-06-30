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

        for my $t (@{ $tests->{parse_datetime_tests} }) {
            my ($str, $exp_result) = @$t;
            subtest $str => sub {
                my $dt;
                eval { $dt = $parser->parse_datetime(
                    $str, {time_zone => $tests->{time_zone}}) };
                my $err = $@;
                if ($exp_result) {
                    ok(!$err, "parse should succeed") or return;
                    is("$dt", $exp_result, "result should be $exp_result");
                } else {
                    ok($err, "parse should fail");
                    return;
                }
            };
        } # parse_datetime_tests

        require DateTime::Format::Duration::ISO8601;
        my $pdur = DateTime::Format::Duration::ISO8601->new;
        for my $t (@{ $tests->{parse_datetime_duration_tests} }) {
            my ($str, $exp_result) = @$t;
            subtest $str => sub {
                my $dtdur;
                eval { $dtdur = $parser->parse_datetime_duration($str) };
                my $err = $@;
                if ($exp_result) {
                    ok(!$err, "parse should succeed") or return;
                    is($pdur->format_duration($dtdur), $exp_result,
                       "result should be $exp_result");
                } else {
                    ok($err, "parse should fail");
                    return;
                }
            };
        } # parse_datetime_duration_tests
    };
}

1;
# ABSTRACT: Test DateTime::Format::Alami

=head1 FUNCTIONS

=head2 test_datetime_format_alami($class, \%tests)
