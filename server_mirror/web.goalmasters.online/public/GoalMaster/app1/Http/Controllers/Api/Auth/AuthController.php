<?php

namespace App\Http\Controllers\Api\Auth;

use App\Models\Booking\SchServiceBooking;
use App\Models\Customer\CmnUserBalance;
use Exception;
use App\Models\User;
use App\Enums\UserType;
use App\Jobs\ResetOTPJob;
use Illuminate\Support\Str;
use App\Services\OTPService;
use Illuminate\Http\Request;
use App\Services\WhatsAppService;
use Illuminate\Support\Facades\DB;
use App\Http\Requests\LoginRequest;
use App\Http\Controllers\Controller;
use App\Models\Customer\CmnCustomer;
use App\Models\Booking\SchServiceBookingInfo;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Http\Requests\RgisterRequest;
use App\Http\Requests\ValidateRequest;
use App\Http\Requests\ChangePasswordRequest;

class AuthController extends Controller
{
    //
    private function SendOtp($customer,$phone_no)
    {
        $OTPService = new OTPService;
        $otp = $OTPService->generateCode();
        $WhatsAppService= new WhatsAppService;
        $customer->otp = $otp;
        $customer->save();
        $WhatsAppService->sendOTP($phone_no,$otp);
        ResetOTPJob::dispatch($customer->id)->delay(now()->addMinutes(5));
    }

    private function ChangePasswords($user , $validate)
    {
        if (Auth::guard('api')->check()) {
            Auth::guard('api')->logout();
        }
        $user->password = Hash::make($validate['password']);
        $user->reset_token = null;
        $user->save();
        $token = Auth::guard('api')->login($user);
        return $token;
    }


    public function login(LoginRequest $request)
    {
        try{
            $validate = $request->validated();
            $credentials = !empty($validate['phone_number']) 
            ? ['phone_number' => $validate['phone_number'], 'password' => $validate['password']] 
            : ['username' => $validate['username'], 'password' => $validate['password']];
            $token = Auth::guard('api')->attempt($credentials);
            if(!$token){return response()->json(['status' => "false", 'message' => __('apiValidation.Something went wrong')], 400);}
            $user = Auth::guard('api')->user(); //UserType::getById($user->user_type)
            return response()->json(["status"=>"true", "data" => ["user" => $user,"token" => $token]],200);  
        }catch(\Exception $e){
            return response()->json(['status'=> "false",'errNum'=> $e->getCode(),'message'=> $e->getMessage(), ],500);
        }
    }


    protected function create(RgisterRequest $request)
    {
        DB::beginTransaction();
        try {
            $validated = $request->validated();
            $validated['password'] = Hash::make($validated['password']);
            $user = User::create($validated);
            $token = Auth::guard('api')->login($user);
            $customer = CmnCustomer::updateOrCreate(
                ['phone_no' => $user->phone_number], 
                [
                    'full_name' => $user->name,
                    'user_id' => $user->id
                ] 
            );
            if (!$customer || !$user) {throw new Exception("Failed to create user or customer.");}
            DB::commit(); 
            $this->SendOtp($customer, $user->phone_number);
            $user = $user->load('secUserRole','customers');
            return response()->json(["status" => "true","data" => ["user" => $user ,"token" => $token]], 200);
        } catch (Exception $ex) {
            DB::rollBack(); 
            return response()->json(['status' => "false",'errNum' => $ex->getCode(),'message' => $ex->getMessage(), ], 500);
        }
    }
    
    public function  profile()
    {
        try{
            $user = Auth::guard('api')->user();
            return response()->json(['status' => "true", 'data'=>['user'=>$user]], 200);
        }catch(\Exception $e){
            return response()->json(['status'=> "false",'errNum'=> $e->getCode(),'message'=> $e->getMessage(), ],500);
        }
    }

    public function verifyOtp(ValidateRequest $request)
    {
        try{
            $validate = $request->validated();
            $customer = CmnCustomer::where('phone_no', $validate['phone'])->first();
            if ($customer->otp !== $validate['code']) {
                return response()->json(['status' => "false", 'message' => __('apiValidation.code is not valid')], 200);
            }

            if($validate['forget'] == true){
                $reset_token = Str::random(60);
                $customer->user->reset_token = $reset_token;
                $customer->user->save();
                $customer->otp = null;
                $customer->save();
                return response()->json(['status' => "true", 'data'=>['reset_token'=>$customer->user->reset_token], 'message' => __('apiValidation.The code is valid')], 200);
            }
            $customer->otp = null;
            $customer->is_phone_verified = true;
            $customer->save();
            $token = Auth::guard('api')->login($customer->user);
            return response()->json(['status' => "true", 'data'=>['user'=>$customer->user,'token' => $token],'message' => __('apiValidation.The code is valid')], 200);
         
        }catch(\Exception $e){
            return response()->json(['status'=> "false",'errNum'=> $e->getCode(),'message'=> $e->getMessage(), ],500);
        }
    }

    public function resendOtp(ValidateRequest $request)
    {
        try{
            $validate = $request->validated();
            $user = User::where('phone_number', $validate['phone'])->first();
            $customer = $user->customer;
            $this->SendOtp($customer, $validate['phone']);
            return response()->json(['status' => "true", 'message' => __('apiValidation.OTP sent successfully')], 200);
         }catch(\Exception $e){
            return response()->json(['status'=> "false",'errNum'=> $e->getCode(),'message'=> $e->getMessage(), ],500);
        }
    }

    public function changePassword(ChangePasswordRequest $request)
    {
        try{
            $validate = $request->validated();
            $user = User::where('reset_token',$validate['reset_token'])->first();
            if(!$user){return response()->json(['status' => "false", 'message' => __('apiValidation.Invalid reset token')], 400);}
            $token = $this->ChangePasswords($user,$validate);
            return response()->json(['status' => "true",'data' => ['user'=>$user,'token' =>$token] , 'message' => __('apiValidation.Password changed successfully')], 200);
        }catch(\Exception $e){
            return response()->json(['status'=> "false",'errNum'=> $e->getCode(),'message'=> $e->getMessage(), ],500);
        }
    }
    

    public function changePasswordUser(ChangePasswordRequest $request)
    {
        try{
            if(!Hash::check($request->old_password, Auth::guard('api')->user()->password)){
                return response()->json(['status' => "false", 'message' => __('apiValidation.Invalid old password') , 'errors'=>['old_password' =>  __('apiValidation.Invalid old password')]], 400);
            }
            $validate = $request->validated();
            $user = Auth::guard('api')->user();
            // ?todo change passworf & return token
            $token = $this->ChangePasswords($user,$validate);
            return response()->json(['status' => "true",'data' => ['user'=>$user,'token' =>$token] , 'message' => __('apiValidation.Password changed successfully')], 200);
        }catch(\Exception $e){
            return response()->json(['status'=> "false",'errNum'=> $e->getCode(),'message'=> $e->getMessage(), ],500);
        }
    }


    public function logout()
    {
        try{
            Auth::guard('api')->logout();
            return response()->json(['status' => "true", 'message' => 'User logged out successfully'], 200);
        }catch(\Exception $e){
            return response()->json(['status'=> "false",'errNum'=> $e->getCode(),'message'=> $e->getMessage(), ],500);
        }
    }

    public function refreshToken()
    {
        try {
            $token = Auth::guard('api')->refresh();
            return response()->json(['status' => "true",'data' => ['token' => $token]], 200);
        } catch (\Tymon\JWTAuth\Exceptions\TokenExpiredException $e) {
            return response()->json(['status' => "false",'message' => 'Token has expired, please log in again.',
            ], 401);
        } catch (\Tymon\JWTAuth\Exceptions\JWTException $e) {
            return response()->json(['status' => "false",'message' => 'Token is invalid or missing.',], 401);
        } catch (\Exception $e) {
            return response()->json(['status' => "false",'errNum' => $e->getCode(),'message' => $e->getMessage(),], 500);
        }
    }

    public function Balance()
    {
        try{
            $user = Auth::guard('api')->user();
            return response()->json(['status' => "true", 'data'=>['balance'=>$user->balance()]], 200);
        }catch(\Exception $e){
            return response()->json(['status'=> "false",'errNum'=> $e->getCode(),'message'=> $e->getMessage(), ],500);
        }
    }
    public function deleteAccount(Request $request)
    {
        DB::beginTransaction();
        try {
            $user = Auth::guard('api')->user();
            if (!$user) {
                return response()->json(['status' => 'false', 'message' => __('apiValidation.userNotAuthenticated')], 401);
            }

            $customer = CmnCustomer::where('user_id', $user->id)->first();
            if ($customer) {
                $bookingIds = SchServiceBooking::where('customer_id', $customer->id)
                    ->pluck('id')
                    ->toArray();

                SchServiceBookingInfo::whereIn('sch_service_booking_id', $bookingIds)->delete();
                SchServiceBooking::where('customer_id', $customer->id)->delete();
                $customer->delete();
            }

            
            CmnUserBalance::where('user_id', $user->id)->delete();

         
            $user->delete();

         
            Auth::guard('api')->logout();

            DB::commit();

            return response()->json([
                'status' => 'true',
                'message' => __('apiValidation.accountDeletedSuccessfully')
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => 'false',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    

}
