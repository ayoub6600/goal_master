<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use App\Http\Requests\UpdateProfileRequest;

class ProfileController extends Controller
{
    public function UpdateProfile(UpdateProfileRequest $request)
    {
         try{
            $validate = $request->validated();
            $user = Auth::guard('api')->user();

            // ? Update user info
            $user->update($validate); 
            $user->customer->phone_no = $user->phone_number;
            $user->customer->full_name = $user->username;
            $user->customer->save();
            $user = $user->makeHidden(['customer']);

            Auth::guard('api')->logout();
            $token = Auth::guard('api')->login($user);
            return response()->json(['status' => "true",'data'=>['user'=>$user,'token' => $token],'message' => __('apiValidation.Profile updated successfully')], 200);
         }catch(\Exception $e){
            return response()->json(['status' => "false", 'message' => __('apiValidation.Something went wrong')], 400);
         }
   }
}
