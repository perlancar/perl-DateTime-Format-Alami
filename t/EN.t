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


            ["now"        , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["right now"  , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["just now"   , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["immediately", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S

            ["today"   , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"],
            ["this day", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"],

            ["tomorrow", "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>"],
            ["tom"     , "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>"],

            ["yesterday", "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],
            ["yest"     , "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],

            ["28feb" , "<CUR_YEAR>-02-28"],
            ["28 feb", "<CUR_YEAR>-02-28"],
            ["feb 28", "<CUR_YEAR>-02-28"],

            ["8 may 2011" , "2011-05-08"],
            ["8 may, 2011", "2011-05-08"],

            ["1 day later", "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>"],
            ["1 day ago"  , "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],

        ],
    },
);

done_testing;
