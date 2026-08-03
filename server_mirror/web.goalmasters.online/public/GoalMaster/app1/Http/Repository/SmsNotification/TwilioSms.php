<?php

namespace App\Http\Repository\SmsNotification;

use App\Contract\SmsInterface;
use App\Models\SmsNotification\CmnTwilioConfig;
use ErrorException;
use Exception;
use Twilio\Rest\Client;

class TwilioSms implements SmsInterface
{
    public function sendSms($phoneNo, $message)
    {
        try {
            $smsConfig = CmnTwilioConfig::where('status', 1)->select('sid', 'token', 'phone_no')->first();

            if ($smsConfig == null)
                throw new ErrorException(translate('Twilio SMS configuration not found!'));
            $client = new Client($smsConfig->sid, $smsConfig->token);

            $client->messages->create(
                $phoneNo, //to
                [
                    'from' => $smsConfig->phone_no,
                    'body' => $message
                ]
            );
        } catch (Exception $ex) {
            throw new ErrorException($ex->getMessage());
        }
        return 1;
    }
}
