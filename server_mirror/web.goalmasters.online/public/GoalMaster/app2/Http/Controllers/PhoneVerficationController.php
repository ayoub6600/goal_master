<?php

namespace App\Http\Controllers;

use App\Jobs\ResetOTPJob;
use App\Models\Customer\CmnCustomer;
use App\Models\User;
use App\Services\OTPService;
use App\Services\WhatsAppService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use App\Jobs\ResetPhoneVerificationJob;
use Illuminate\Support\Facades\RateLimiter;

class PhoneVerficationController extends Controller
{
    public function phoneVerification()
    {
        return view('auth.verify');
    }

    public function phoneVerificationverify(Request $request)
    {
        $request->validate([
            'code' => 'required|numeric',
        ]);
        $user_id = Auth::id();
        $user = User::find($user_id);
        $customer = CmnCustomer::where('user_id', $user->id)->first();
        if (!$user) {
            return redirect()->route('login')->with('error', 'المستخدم غير موجود.');
        }
        if ($customer->otp !== $request->input('code')) {
            return redirect()->back()->with('error', 'كود التحقق غير صحيح.');
        }
        $customer->otp = null;
        $customer->is_phone_verified = true;
        $customer->save();
        return redirect()->route('home')->with('success', 'تم التحقق من رقم الهاتف بنجاح.');
    }


    public function phoneVerificationresend()
    {
        $user_id = Auth::id();
        $user = User::find($user_id);
        if (!$user) {
            return redirect()->back()->with('error', 'المستخدم غير موجود.');
        }
        $cacheKey = "resend_verification_code_{$user_id}";
        if (Cache::has($cacheKey)) {
            $remainingTime = Cache::get($cacheKey) - now()->timestamp;
            return redirect()->back()->with('error', "يرجى الانتظار {$remainingTime} ثانية قبل طلب كود جديد.");
        }
        $customer = CmnCustomer::where('user_id', $user->id)->first();
        if ($customer) {
            $OTPService = new OTPService;
            $otp = $OTPService->generateCode();
            $WhatsAppService = new WhatsAppService;
            $customer->otp = $otp;
            $customer->save();
            $WhatsAppService->sendOTP($customer->phone_no, $otp);
            Cache::put($cacheKey, now()->addMinutes(5)->timestamp, now()->addMinutes(5));
            ResetOTPJob::dispatch($customer->id)->delay(now()->addMinutes(5));
            return redirect()->back()->with('success', 'تم إرسال كود التحقق بنجاح.');
        }
        return redirect()->back()->with('error', 'لم يتم العثور على سجل للعميل.');
    }


    public function is_phone_verified(Request $request)
    {
        $isphoneVerified = false;
        $user = Auth::user();
        $customer = '';
        if ($user) {
            $customer = CmnCustomer::where('user_id', $user->id)->first();
        } else {
            $user = User::where('phone_number', $request->phone)->first();
            if($user){
                // return redirect('login');
                return response()->json(['redirect' => url('login')]);
            }
            $customer = CmnCustomer::where('phone_no', $request->phone)->first();
        }

        if ($customer && $customer->is_phone_verified) {
            $isphoneVerified = true;
        } else {
            $customer = CmnCustomer::firstOrCreate(
                [
                    'phone_no' => $request->phone,
                ],
                [
                    'user_id' => null,
                    'full_name' => $request->full_name
                ],
            );
        }
        return response()->json(['isphoneVerified' => $isphoneVerified]);
    }

    public function guest_phone_Verification_send(Request $request)
    {
        $phone = $request->phone;

        $decaySeconds = 2 * 60;
        $cacheKey = 'otp-request:' . $phone;
        $lastRequestTime = Cache::get($cacheKey);
        if ($lastRequestTime && now()->timestamp - $lastRequestTime < $decaySeconds) {
            $remainingTime = $decaySeconds - (now()->timestamp - $lastRequestTime);
            return response()->json(['status' => 0, 'message' => "يرجى الانتظار {$remainingTime} ثانية قبل طلب كود التحقق الجديد."], 200);
        }

        $user = Auth::user();
        if ($user) {
            $customer = CmnCustomer::where('user_id', $user->id)->first();
            if ($customer && $customer->is_phone_verified) {
                return response()->json(['status' => 0, 'message' => 'تم التحقق من رقم الهاتف بالفعل.'], 200);
            }
        }
        $customer = CmnCustomer::where('phone_no', $phone)->first();
        if (!$customer) {
            return response()->json(['status' => 0, 'message' => 'لم يتم العثور على العميل.'], 400);
        } else if ($customer->is_phone_verified) {
            return response()->json(['status' => 0, 'message' => 'تم التحقق من رقم الهاتف بالفعل.'], 200);
        }

        $OTPService = new OTPService;
        $otp = $OTPService->generateCode();
        $WhatsAppService = new WhatsAppService;
        $customer->otp = $otp;
        $customer->save();
        $WhatsAppService->sendOTP($phone, $otp);
        Cache::put($cacheKey, now()->timestamp, $decaySeconds);
        ResetOTPJob::dispatch($customer->id)->delay(now()->addMinutes(5));
    }

    public function guest_phone_Verification_verify(Request $request)
    {
        $request->validate([
            'code' => 'required|numeric',
            'phone' => 'required|numeric'
        ]);

        $user_id = Auth::id();
        $customer = '';

        if ($user_id) {
            $user = User::find($user_id);
            $customer = CmnCustomer::where('user_id', $user->id)->first();
        } else {
            $customer = CmnCustomer::where('phone_no', $request->phone)->first();
        }

        if ($customer->otp !== $request->input('code')) {
            return response()->json(['status' => 0, 'message' => 'كود التحقق غير صحيح'], 200);
        }
        $customer->otp = null;
        $customer->is_phone_verified = true;
        $customer->save();
        if (!$user_id) {
            ResetPhoneVerificationJob::dispatch($customer->id)->delay(now()->addSeconds(30));
        }
        return response()->json(['status' => 1, 'message' => 'تم التحقق من رقم الهاتف بنجاح'], 200);
    }

    public function guest_phone_Verification_resend(Request $request)
    {
        $phone = $request->phone;

        $decaySeconds = 2 * 60;
        $cacheKey = 'otp-request:' . $phone;
        $lastRequestTime = Cache::get($cacheKey);
        if ($lastRequestTime && now()->timestamp - $lastRequestTime < $decaySeconds) {
            $remainingTime = $decaySeconds - (now()->timestamp - $lastRequestTime);
            return response()->json(['status' => 0, 'message' => "يرجى الانتظار {$remainingTime} ثانية قبل طلب كود التحقق الجديد."], 200);
        }

        // Retrieve customer data based on authenticated user or phone number
        $customer = Auth::user()
            ? CmnCustomer::where('user_id', Auth::user()->id)->first()
            : CmnCustomer::where('phone_no', $phone)->first();

        // Check if the customer is found and phone is already verified
        if (!$customer) {
            return response()->json(['status' => 0, 'message' => 'لم يتم العثور على العميل'], 400);
        }

        if ($customer->is_phone_verified) {
            return response()->json(['status' => 0, 'message' => 'تم التحقق من رقم الهاتف بالفعل'], 200);
        }

        // Generate and send OTP
        $OTPService = new OTPService;
        $otp = $OTPService->generateCode();

        // Save OTP to customer record
        $customer->otp = $otp;
        $customer->save();

        // Send OTP via WhatsApp (or other communication service)
        $WhatsAppService = new WhatsAppService;
        $WhatsAppService->sendOTP($phone, $otp);

        // Store the current timestamp as the last request time
        Cache::put($cacheKey, now()->timestamp, $decaySeconds);
        ResetOTPJob::dispatch($customer->id)->delay(now()->addMinutes(5));

        return response()->json(['status' => 1, 'message' => 'تم إعادة إرسال كود التحقق بنجاح'], 200);
    }
}
