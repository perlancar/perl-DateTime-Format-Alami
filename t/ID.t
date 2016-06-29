#!perl

use 5.010001;
use strict;
use warnings;

use Test::DateTime::Format::Alami;
use Test::More 0.98;

test_datetime_format_alami(
    "ID",
    {
        parse_datetime_tests => [
            ["foo", undef],

            # p_now
            ["saat inilah" , undef], # sanity
            ["saat ini" , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["saat  ini", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # test multiple spaces
            ["Saat Ini" , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # test case
            ["sekarang" , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["skrg"     , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S

            # p_today
            ["hari ini", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>T00:00:00"],

            # p_tomorrow
            ["besok", "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>T00:00:00"],
            ["esok" , "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>T00:00:00"],

            # p_yesterday
            ["kemarin", "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>T00:00:00"],
            ["kemaren", "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>T00:00:00"],
            ["kmrn"   , "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>T00:00:00"],

            # p_dateymd
            ["28martian", undef], # sanity
            ["28feb" , "<CUR_YEAR>-02-28"],
            ["28februari", "<CUR_YEAR>-02-28"],
            ["28 feb", "<CUR_YEAR>-02-28"],
            ["28-feb", "<CUR_YEAR>-02-28"],
            ["28/feb", "<CUR_YEAR>-02-28"],

            ["2/1", "<CUR_YEAR>-01-02"],
            ["28/2"  , "<CUR_YEAR>-02-28"],
            ["28/299", undef], # sanity

            ["8 mei 2011", "2011-05-08"],
            ["8-mei-2011", "2011-05-08"],
            ["8-05-2011" , "2011-05-08"],
            ["8-5-2011"  , "2011-05-08"],
            ["8-5-11"    , "2011-05-08"],
            ["8/5/11"    , "2011-05-08"],

            # p_dur_ago, p_dur_later
            ["1 hari lagi"     , "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>"],
            ["1 hari yang lalu", "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],

            # p_time
            ["11:00", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>T11:00:00"],
            ["11:00:05", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>T11:00:05"],
            ["23.00", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>T23:00:00"],

            # p_date_time
            ["28 jun 11:00", "<CUR_YEAR>-06-28T11:00:00"],
            ["28 jun 11 11:00", "2011-06-28T11:00:00"],
            ["28 jun 2011 11.00", "2011-06-28T11:00:00"],
            ["28 jun, 11 23:00:05", "2011-06-28T23:00:05"],

        ],

        parse_datetime_duration_tests => [
            ["foo", undef],

            # pdur_dur
            ["2h 3j", "P2DT3H"],
            ["2 hari, 3 jam", "P2DT3H"],
        ],
    },
);

done_testing;
