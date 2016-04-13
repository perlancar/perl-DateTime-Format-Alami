#!perl

use 5.010001;
use strict;
use warnings;

use Test::DateTime::Format::Alami;
use Test::More 0.98;

test_datetime_format_alami(
    "ID",
    {
        parse_tests => [
            ["foo", undef],

            ["saat inilah" , undef], # sanity
            ["saat ini" , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["saat  ini", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # test multiple spaces
            ["Saat Ini" , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # test case
            ["sekarang" , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S
            ["skrg"     , "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"], # XXX test H:M:S

            ["hari ini", "<CUR_YEAR>-<CUR_MONTH>-<CUR_DAY>"],

            ["besok", "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>"],
            ["esok" , "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>"],

            ["kemarin", "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],
            ["kemaren", "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],
            ["kmrn"   , "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],

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

            ["1 hari lagi"     , "<YEAR_TOMORROW>-<MONTH_TOMORROW>-<DAY_TOMORROW>"],
            ["1 hari yang lalu", "<YEAR_YESTERDAY>-<MONTH_YESTERDAY>-<DAY_YESTERDAY>"],

        ],
    },
);

done_testing;
