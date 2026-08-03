<?php

namespace App\Http\Controllers\UserManagement;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Settings\CmnBranch;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserManagement\SecUserBranch;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Hash;
use App\Models\UserManagement\SecUserRole;
use Illuminate\Support\Facades\File;
use Carbon\Carbon;
use ErrorException;
use App\Models\Customer\CmnCustomer;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Booking\SchServiceBooking;
use App\Models\Customer\CmnUserBalance;



class UserController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function user()
    {
        $isSystemUser = false;

        $user = User::where('id', Auth()->id())->first();
        $userType = $user->user_type;
        if (!$user->is_sys_adm && $userType != 2) {
            $isSystemUser = true;
        }


        return view('user_management.user', ['isSystemUser' =>  $isSystemUser, 'isAdmin' => $user->is_sys_adm]);
    }

    public function changePassword()
    {
        return view('user_management.change_password');
    }

    public function changeProfilePhoto()
    {
        return view('user_management.change_profile_photo', ['profilePhoto' => auth()->user()->photo]);
    }

    /**
     * This Method use for only update user profile photo
     * Author: kaysar
     * Date: 16-Jan-2021
     * @param Request $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateUserProfilePhoto(Request $request)
    {
        try {

            $filePath = $request->profilePhoto;
            if ($filePath != null) {
                $filePath = UtilityRepository::saveFile($filePath, ['image/PNG', 'image/png', 'image/jpg', 'image/jpeg']);
            }

            $user = User::where('id', auth()->id())->first();
            if ($user != null) {
                $user->photo = $filePath;
                $user->update();
            }
            return redirect()->route('change.user.profile.photo');
        } catch (Exception $ex) {
            return redirect()->route('error.display', ['msg' => "Something went wrong please try again."]);
        }
    }

    /**
     * This method use for update old password
     * Author:kaysar
     * Date: 16-Jan-2021
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateUserPassword(Request $request)
    {
        try {
            $validator = Validator::make($request->toArray(), [
                'currentPassword' => ['required', 'string', 'min:8'],
                'newPassword' => ['required', 'string', 'min:8', 'same:newConfirmPassword'],
                'newConfirmPassword' => ['required', 'string', 'min:8']
            ]);

            if (!$validator->fails()) {
                $userInfo = User::where('id', auth()->id())->first();
                if (Hash::check($request->currentPassword, $userInfo->password)) {
                    $userInfo->password = Hash::make($request->newPassword);
                    $userInfo->update();
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                } else {
                    return $this->apiResponse(['status' => '-1', 'data' => ''], 200);
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Summary of getUserInfo
     * Auth: kaysar
     * Date: 12-Dec-2020
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUserInfo()
    {

        $user = User::where('id', Auth()->id())->first();
        // $userType =$user->user_type;

        try {

            if ($user->is_sys_adm) {
                $data = DB::table('users as u')
                    ->leftJoin('sec_user_roles as ur', 'u.id', '=', 'ur.sec_user_id')
                    ->leftJoin('sec_roles as r', 'ur.sec_role_id', '=', 'r.id')
                    ->leftJoin('sch_employees as emp', 'u.sch_employee_id', '=', 'emp.id')
                    ->select('u.id', 'u.name', 'u.phone_number', 'u.username', 'u.photo', 'u.status', 'ur.sec_role_id', 'r.name as role', 'u.user_type', 'u.sch_employee_id', 'emp.full_name as employee')->get();
            } else {
                $data = DB::table('users as u')
                    ->leftJoin('sec_user_roles as ur', 'u.id', '=', 'ur.sec_user_id')
                    ->leftJoin('sec_roles as r', 'ur.sec_role_id', '=', 'r.id')
                    ->leftJoin('sch_employees as emp', 'u.sch_employee_id', '=', 'emp.id')
                    ->select('u.id', 'u.name', 'u.phone_number', 'u.username', 'u.photo', 'u.status', 'ur.sec_role_id', 'r.name as role', 'u.user_type', 'u.sch_employee_id', 'emp.full_name as employee')
                    ->where('u.created_by', auth()->id())
                    ->get();
            }


            $userBranch = SecUserBranch::join('cmn_branches', 'sec_user_branches.cmn_branch_id', '=', 'cmn_branches.id')
                ->select('cmn_branches.id', 'cmn_branches.name', 'sec_user_branches.user_id')->get();
            foreach ($data as &$val) {

                ///////////////////////////////////////////
                //for send users balance data
                $userId = $val->id;
                $userBal =  User::where('id', $userId)->first();
                $totalBalance = $userBal->balance();

                // $totalBalance = DB::table('cmn_user_balances')
                //     ->where('user_id', $userId)
                //     ->sum('amount');
                $val->totalBalance = $totalBalance;
                ////////////////////////////////////////////

                $val->userBranch = $userBranch->where('user_id', $val->id)->values();
            }
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (QueryException $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }



    /**
     * Summary of createUser
     * create user by ajax request
     *  Auth: kaysar
     *  Date: 12-Dec-2020
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function createUser(Request $data)
    {
        if ($data->userType == 'WebUser') {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:255'],
                'username' => ['required', 'max:100', 'unique:users'],
                'password' => ['required', 'string', 'min:8', 'confirmed'],
                'phone_no' => ['required', 'numeric', 'unique:users,phone_number']
            ], [
                'phone_no.required' => 'The phone number field is required.',
                'phone_no.numeric' => 'The phone number must be a number.',
                'phone_no.unique' => 'This phone number is already in use.',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
            }
            DB::beginTransaction();
            try {
                $user = User::create([
                    'name' => $data['name'],
                    // 'email' => $data['email'],
                    'username' => $data['username'],
                    'password' => Hash::make($data['password']),
                    // 'email_verified_at' => Carbon::now(),
                    'phone_number' => $data['phone_no'],
                    'status' => 1,
                    'user_type' => UserType::WebsiteUser,
                    'created_by' => auth()->id(),

                ]);
                $customer = CmnCustomer::create([
                    'full_name' => $data['name'],
                    'user_id' => $user->id,
                    // 'email' => $data['email'],
                    'phone_no' => $data['phone_no'],
                    'created_by' => auth()->id(), 

                ]);
                DB::commit();
                return $user;
            } catch (Exception $ex) {
                DB::rollBack();
                return $ex;
            }
            return $this->apiResponse(['status' => '1', 'data' => 'WebUser'], 200);
        }
        DB::beginTransaction();
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:255'],
                // 'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
                // 'phone_number' => ['required', 'numeric', 'unique:users'],
                'username' => ['required', 'max:100', 'unique:users'],
                'password' => ['required', 'string', 'min:8', 'confirmed'],
                'sec_role_id' => ['required', 'int'],
                'status' => ['required', 'int']
            ]);

            if (!$validator->fails()) {
                $user = User::create([
                    'name' => $data->name,
                    'username' => $data->username,
                    'password' => Hash::make($data->password),
                    'status' => $data->status,
                    // 'email' => $data->email,
                    // 'email_verified_at' => Carbon::now(),
                    // 'phone_number' => $data->phone_number,
                    'user_type' => UserType::SystemUser,
                    'sch_employee_id' => $data->sch_employee_id == "" ? null : $data->sch_employee_id
                ]);
                $user->secUserRole()->create([
                    'sec_role_id' => $data->sec_role_id,
                    'status' => 1,
                    'created_by' => auth()->id()
                ]);

                //user branch
                $userBranch = array();
                foreach (explode(',', $data->cmn_branch_id) as $val) {
                    if ($val != "") {
                        $userBranch[] = [
                            'user_id' => $user->id,
                            'cmn_branch_id' => $val,
                            'created_by' => auth()->id()
                        ];
                    }
                }
                if (count($userBranch) > 0)
                    SecUserBranch::insert($userBranch);

                DB::commit();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            DB::rollBack();
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }



    /**
     * Summary of updateUserInfo
     *  Update user information
     *  Auth: kaysar
     *  Date: 18-Dec-2020
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateUserInfo(Request $data)
    {
        DB::beginTransaction();
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:255'],
                // 'email' => ['required', 'string', 'email', 'max:255'],
                // 'phone_number' => ['required', 'numeric'],
                'username' => ['required', 'max:100'],
                // 'sec_role_id' => ['required', 'int'],
                'password' => ['required', 'string', 'min:8', 'confirmed'],
                // 'status' => ['required', 'int']
            ]);

            if (!$validator->fails()) {
                $reqBranch = array_filter(explode(',', $data->cmn_branch_id));
                $userInfo = User::where('id', $data->id)->first();

                if ($userInfo->user_type == UserType::WebsiteUser)
                    throw new ErrorException("You can't edit web user.");

                if ($userInfo->is_sys_adm && ($data->sch_employee_id || count($reqBranch) > 0))
                    throw new ErrorException("Is not possible to set employee & branch against the system user.");

                $userInfo->name = $data->name;
                // $userInfo->email = $data->email;
                $userInfo->phone_number = $data->phone_number;
                $userInfo->username = $data->username;
                $userInfo->status = $data->status;

                if ($userInfo->user_type != UserType::WebsiteUser)
                    $userInfo->sch_employee_id = $data->sch_employee_id == "" ? null : $data->sch_employee_id;
                if ($data->password != '00000000')
                    $userInfo->password = Hash::make($data->password);
                $userInfo->update();
                SecUserRole::where('sec_user_id', $data->id)->update(['sec_role_id' => $data->sec_role_id]);

                //set user branch if not web user
                if ($userInfo->user_type != UserType::WebsiteUser) {
                    //delete deselect user branch                
                    SecUserBranch::where('user_id', $userInfo->id)->whereNotIn('cmn_branch_id',  $reqBranch)->delete();
                    $userBranch = array();
                    $existingBranch = SecUserBranch::where('user_id', $userInfo->id)->select('cmn_branch_id')->get();
                    foreach ($reqBranch as $val) {
                        if ($val != "" && collect($existingBranch)->where('cmn_branch_id', $val)->count() < 1) {
                            $userBranch[] = [
                                'user_id' => $userInfo->id,
                                'cmn_branch_id' => $val,
                                'created_by' => auth()->id()
                            ];
                        }
                    }
                    if (count($userBranch) > 0)
                        SecUserBranch::insert($userBranch);
                }
                DB::commit();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    /**
     * Summary of deleteUserInfo
     *  Delete user information
     *  Auth: kaysar
     *  Date: 18-Dec-2020
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteUserInfo(Request $data)
    {
        try {
            
            $user = User::where('id', $data->id)->first();
            $userType =$user->user_type;
            if($user->is_sys_adm)
            {
                return $this->apiResponse(['status' => '501', 'data' => 'You can not delete super admin user'], 400);   
            }
            else if (!($user->is_sys_adm || $userType  == 2)) {

                SecUserRole::where('sec_user_id', $data->id)->delete();
                SecUserBranch::where('user_id', $data->id)->delete();
                $rtr = User::destroy($data->id);
                return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
            }
            else {

                $customerID=CmnCustomer::where('user_id', $data->id)->first();
                
                            
                if ($customerID) {
                    // Check and delete related bookings
                    $SchServiceBookingInfoIDs = SchServiceBookingInfo::where('cmn_customer_id', $customerID->id)->pluck('id');
                    
                    if ($SchServiceBookingInfoIDs->isNotEmpty()) {
                        SchServiceBooking::whereIn('sch_service_booking_info_id', $SchServiceBookingInfoIDs)->delete();
                        SchServiceBookingInfo::where('cmn_customer_id', $customerID->id)->delete();
                    }
                    
                    // Delete customer record
                    CmnCustomer::where('user_id', $data->id)->delete();
                }
                
                // Check and delete user role
                if (SecUserRole::where('sec_user_id', $data->id)->exists()) {
                    SecUserRole::where('sec_user_id', $data->id)->delete();
                }
                
                // Check and delete user balance
                if (CmnUserBalance::where('user_id', $data->id)->exists()) {
                    CmnUserBalance::where('user_id', $data->id)->delete();
                }
                
                // $SchServiceBookingInfoID=SchServiceBooking::where('cmn_customer_id', $customerID->id)->get();
                
                
                // SecUserRole::where('sec_user_id', $data->id)->delete();
                // CmnUserBalance::where('user_id', $data->id)->delete();
                // SchServiceBooking::whereIn('sch_service_booking_info_id', $SchServiceBookingInfoID)->delete();
                // SchServiceBookingInfo::where('cmn_customer_id', $customerID->id)->delete();
                // CmnCustomer::where('user_id', $data->id)->delete();
                $rtr = User::destroy($data->id);
                return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
            }
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    public function getSystemUser()
    {
        try {
            $data = User::select('id', 'name')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
