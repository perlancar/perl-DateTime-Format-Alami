#!perl

use 5.010001;
use strict;
use warnings;

use DateTime::Format::Alami::ID;
use Test::More 0.98;

my $p = DateTime::Format::Alami::ID->new;
my $str = "19-6-11, 21-6-11, 20-6-11";
my $tz = 'Asia/Jakarta';

#subtest "time_zone" => sub {
#    my $res = $p->parse_datetime('19-6-11 pukul 5 pagi', {time_zone=>'Asia/Jakarta'});
#};

subtest "format=DateTime" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz});
    is(ref($res), "DateTime");
    is($res->ymd, "2011-06-19");
};

subtest "format=verbatim" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz, format=>'verbatim'});
    is($res, "19-6-11");
};

subtest "format=epoch" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz, format=>'epoch'});
    is($res, 1308416400);
};

subtest "format=combined" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz, format=>'combined'});
    is(ref($res), "HASH");
    is($res->{DateTime}->ymd, "2011-06-19");
    is($res->{verbatim}, "19-6-11");
    is($res->{epoch}, 1308416400);
    is_deeply($res->{m}, {o_dayint=>19, o_monthint=>6, o_yearint=>11, p_dateymd=>'19-6-11'});
    is($res->{pattern}, 'p_dateymd');
    is($res->{pos}, 0);
    is($res->{uses_time}, 0);
};

#subtest "prefers" => sub {
#};

subtest "returns=last" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz, format=>'verbatim', returns=>'last'});
    is($res, "20-6-11");
};

subtest "returns=earliest" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz, format=>'verbatim', returns=>'earliest'});
    is($res, "19-6-11");
};

subtest "returns=latest" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz, format=>'verbatim', returns=>'latest'});
    is($res, "21-6-11");
};

subtest "returns=all" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz, format=>'verbatim', returns=>'all'});
    is_deeply($res, ["19-6-11", "21-6-11", "20-6-11"]);
};

subtest "returns=latest" => sub {
    my $res = $p->parse_datetime($str, {time_zone => $tz, format=>'verbatim', returns=>'all_cron'});
    is_deeply($res, ["19-6-11", "20-6-11", "21-6-11"]);
};

done_testing;
