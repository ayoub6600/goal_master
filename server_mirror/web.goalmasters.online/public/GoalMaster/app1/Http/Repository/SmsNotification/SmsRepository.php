<?php

namespace App\Http\Repository\SmsNotification;

use App\Contract\SmsInterface;

class SmsRepository
{
    private $smsGatway;
    public function __construct(SmsInterface $smsGatway)
    {
       $this->smsGatway = $smsGatway;
    }

    public function send($phoneNo, $message)
    {
        return $this->smsGatway->sendSms($phoneNo, $message);
    }

}
