<?php

namespace App\Http\Controllers\Auth;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Jobs\ResetOTPJob;
use App\Models\Customer\CmnCustomer;
use App\Providers\RouteServiceProvider;
use App\Models\User;
use Illuminate\Foundation\Auth\RegistersUsers;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Database\Events\QueryExecuted;
use Illuminate\Database\QueryException;
use Exception;
use App\Models\UserManagement\SecRole;
use App\Services\OTPService;
use App\Services\WhatsAppService;
use Illuminate\Support\Facades\DB;


class RegisterController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Register Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles the registration of new users as well as their
    | validation and creation. By default this controller uses a trait to
    | provide this functionality without requiring any additional code.
    |
     */

    use RegistersUsers;

    /**
     * Where to redirect users after registration.
     *
     * @var string
     */
    // protected $redirectTo = RouteServiceProvider::HOME;
    protected $redirectTo = RouteServiceProvider::PhoneVerification;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('guest');
    }

    /**
     * Get a validator for an incoming registration request.
     *
     * @param  array  $data
     * @return \Illuminate\Contracts\Validation\Validator
     */
    protected function validator(array $data)
    {
        return Validator::make($data, [
            'name' => ['required', 'string', 'max:255'],
            // 'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'username' => ['required', 'max:100', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'phone_no' => ['required', 'numeric', 'unique:users,phone_number','regex:/^09[0-9]{8}$/']
        ],[
            'name.required' => 'يجب ادخال الاسم.',
            'username.required' => 'يجب ادخال اسم المستخدم.',
            'username.unique' => 'اسم المستخدم مسجل من قبل.',
            'password.required' => 'يجب ادخال كلمة المرور.',
            'password.min' => 'كلمة المرور يجب ان تكون على الاقل 8 حروف.',
            'password.confirmed' => 'كلمة المرور غير متطابقة.',
            'phone_no.required' => 'يجب ادخال رقم الجوال.',
            'phone_no.numeric' => 'يجب ان يكون رقم الجوال رقم.',
            'phone_no.unique' => 'هذا الرقم مسجل من قبل.',
            'phone_no.regex' => 'رقم الجوال غير صحيح يجب أن يبدا ب 09 و يتكون من 10 رقم.'
        ]);
    }

    /**
     * Create a new user instance after a valid registration.
     *
     * @param  array  $data
     * @return \App\Models\User
     */
    protected function create(array $data)
    {
        DB::beginTransaction();
        try {
            $user = User::create([
                'name' => $data['name'],
                // 'email' => $data['email'],
                'username' => $data['username'],
                'password' => Hash::make($data['password']),
                'status' => 1,
                'user_type' => UserType::WebsiteUser,
                'phone_number'=> $data['phone_no']
            ]);
            $customer = CmnCustomer::updateOrCreate(
                ['phone_no' => $data['phone_no']],
                [
                    'full_name' => $data['name'],
                    'user_id' => $user->id
                ]
            );            
            DB::commit();
            if($customer && $user) {
                $OTPService = new OTPService;
                $otp = $OTPService->generateCode();
                $WhatsAppService= new WhatsAppService;
                $customer->otp = $otp;
                $customer->save();
                $WhatsAppService->sendOTP($data['phone_no'],$otp);
                ResetOTPJob::dispatch($customer->id)->delay(now()->addMinutes(5));
            }
            return $user;
        } catch (Exception $ex) {
            DB::rollBack();
            return $ex;
        }
    }
}
