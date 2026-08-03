<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SmsNotification\CmnTwilioConfig;
use App\Models\SmsNotification\StOtpConfiguration;
use App\Models\SmsNotification\StOtpMessage;

class SMSController extends Controller
{
    function index(){
        return view('settings.sms',['twilio' => CmnTwilioConfig::first()]);    
    }

    function twilio(Request $request){
        $request->validate([
            'sid' => 'bail|required_if:status,1',
            'token' => 'bail|required_if:status,1',
            'phone_no' => 'bail|required_if:status,1'
        ]);

        $setup = CmnTwilioConfig::first();
        if(!$setup){
            $setup = new CmnTwilioConfig();
            $setup->created_by = auth()->id();
        }

        $setup->sid = $request->sid;
        $setup->token = $request->token;
        $setup->phone_no = $request->phone_no;
        $setup->status = ($request->status)?1:0;
        $setup->updated_by = auth()->id();
        $setup->save();

        return redirect()->route('sms.index')->with('success','Twilio Config Update Successful!!');
    }

    function otp(){
        return view('settings.otp',['otp' => StOtpConfiguration::first(), 'otp_messages' => StOtpMessage::get()]);
    }

    function otpUpdate(Request $request){
        $stOtpConfiguration = StOtpConfiguration::first();
        $stOtpConfiguration->status = ($request->status)?1:0;
        $stOtpConfiguration->updated_by = auth()->id();
        $stOtpConfiguration->update();

        foreach($request->message as $keyId => $message){
            $item = StOtpMessage::find($keyId);
            $item->message = $message;
            $item->updated_by = auth()->id();
            $item->update();
        }

        return redirect()->route('sms.otp')->with('success','OTP Config Update Successful!!');
    }
}
