<?php

namespace App\Contract;

interface SmsInterface
{
    public function sendSms($phoneNo,$message);
}