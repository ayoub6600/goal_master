<?php

namespace App\Http\Repository\SmsNotification;

use App\Enums\SmsGateway;
use App\Models\SmsNotification\StOtpConfiguration;
use App\Models\SmsNotification\StOtpMessage;

class SmsNotificationRepository
{
    /**
     * phone=88018222222
     * messageType enum (like done,cancel,messageOnly) 
     * $tagValueList=[['key'=>'{invNo}','value'=>'34322'],['key'=>'{invNo}','value'=>'34322']];
     */
    public static function sendNotification($phone, $messageType, $tagValue = [])
    {
        $otpMessage = StOtpMessage::where('message_type', $messageType)->where('status', 1)->select('message_type', 'message_for', 'tags', 'message')->first();
        if ($otpMessage != null) {
            $otpConfiguration = StOtpConfiguration::where('status', 1)->select('name', 'sms_gateway')->first();
            $message = $otpMessage->message;
            //replace tag value into the message
            foreach ($tagValue as $tag) {
                $message = str_replace($tag['key'], $tag['value'], $message);
            }
            $message = $message . " \n" . env("APP_NAME");
            //twilio sms gateway
            if ($otpConfiguration->sms_gateway == SmsGateway::Twilio) {
                $twilo = new TwilioSms();
                $smsRepo = new SmsRepository($twilo);
                $smsRepo->send($phone, $message);
            }
        }
    }
}
