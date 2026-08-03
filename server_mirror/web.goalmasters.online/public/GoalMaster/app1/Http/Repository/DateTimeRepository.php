<?php

namespace App\Http\Repository;

class DateTimeRepository
{
    public static function TotalMinuteFromTime($time)
    {
        $timArr = explode(':', $time);
        $totalMinute = ($timArr[0] * 60) + $timArr[1] + ($timArr[2] / 60);
        return $totalMinute;
    }

    public static function MinuteToTime($minute)
    {
        $da = date('H:i:s', mktime(0, $minute,0));

        return $da;
    }

    public static function TotalMinuteFromDays($days)
    {
        return 1440 * $days;
    }

    public static function TotalMinuteFromDateDiff($dateFrom,$dateTo)
    {
        $d1 = strtotime($dateFrom);
        $d2 = strtotime($dateTo);
        $totalSecondsDiff = abs($d1-$d2); //42600225
        $totalMinutesDiff = $totalSecondsDiff/60; //710003.75
        return $totalMinutesDiff;
    }


}
