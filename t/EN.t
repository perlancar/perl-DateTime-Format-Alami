#!perl

use 5.010001;
use strict;
use warnings;

use Test::DateTime::Format::Alami;
use Test::More 0.98;

test_datetime_format_alami(
    "EN",
    {
        parse_tests => [
            ["foo", undef],

            ["nowadays"   , undef], # sanity
            ["now"        , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["right   now", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # test multiple spaces
            ["right now"  , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["just now"   , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["JUST NOW"   , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # tets case
            ["immediately", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S

            ["today"   , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>T00:00:00"],
            ["this day", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>T00:00:00"],

            ["tomorrow", "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>T00:00:00"],
            ["tom"     , "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>T00:00:00"],

            ["yesterday", "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>T00:00:00"],
            ["yest"     , "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>T00:00:00"],

            ["28febby", undef], # sanity
            ["28feb" , "<CUR_YEAR>-02-28"],
            ["28february", "<CUR_YEAR>-02-28"],
            ["28 feb", "<CUR_YEAR>-02-28"],
            ["feb 28", "<CUR_YEAR>-02-28"],

            ["2/1", "<CUR_YEAR>-02-01"],
            ["2/28", "<CUR_YEAR>-02-28"],
            ["28/299", undef], # sanity

            ["8 may 2011" , "2011-05-08"],
            ["8 may, 2011", "2011-05-08"],
            ["5-8-2011", "2011-05-08"],
            ["5-8-11", "2011-05-08"],
            ["5/8/11", "2011-05-08"],

            ["1 day later", "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>"],
            ["1 day ago"  , "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],

        ],
    },
);

done_testing;
