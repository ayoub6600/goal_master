<?php

namespace App\Http\Controllers\Customer;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Customer\CmnCustomer;
use Exception;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Hash;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Booking\SchServiceBooking;
use App\Models\Customer\CmnUserBalance;
use App\Models\UserManagement\SecUserBranch;
use Illuminate\Support\Facades\DB;

class CustomerController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function customer()
    {
        return view('customer.customer');
    }

    // public function customerStore(Request $data)
    // {
    //     try {
    //         $validator = Validator::make($data->all(), [
    //             'full_name' => ['required', 'string'],
    //             // 'email' => ['required', 'string', 'unique:cmn_customers,email'],
    //             'phone_no' => ['required', 'string', 'unique:cmn_customers,phone_no', 'max:20'],
    //             // 'street_address' => ['required', 'string']
    //         ]);
    //         if (!$validator->fails()) {
    //             $data['user_id'] =  $data['user_id'] = UtilityRepository::emptyToNull($data->user_id);
    //             //create new user
    //             // if ($data->user_id == 0) {
    //             //     $userId =   User::create(
    //             //         [
    //             //             'name' => $data->full_name,
    //             //             'username' => $data->phone_no,
    //             //             'password' => Hash::make('12345678'),
    //             //             'phone_number' => $data->phone_no,
    //             //             'is_phone_verfied' => true,
    //             //             // 'email' => $data->email,
    //             //             // 'email_verified_at' => Carbon::now(),
    //             //             'is_sys_adm' => 0,
    //             //             'status' => 1,
    //             //             'user_type' => UserType::WebsiteUser,
    //             //             'created_by' => auth()->id(), // Add this line

    //             //         ]
    //             //     );
    //             //     $data['user_id'] = $userId->id;
    //             // }

    //             $data['created_by'] = auth()->id();
    //             $data['id'] = null;
    //             $data['created_at'] = auth()->id();
    //             // $data['dob']=UtilityRepository::emptyToNull($data->dob);
    //             $rtr = CmnCustomer::create($data->all());
    //             return $this->apiResponse(['status' => '1', 'data' => ['cmn_customer_id' => $rtr->id]], 200);
    //         }
    //         return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
    //     } catch (Exception $ex) {
    //         return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
    //     }
    // }

    // public function customerUpdate(Request $data)
    // {
    //     try {
    //         $validator = Validator::make($data->all(), [
    //             'full_name' => ['required', 'string'],
    //             // 'email' => ['required', 'string', 'unique:cmn_customers,email,' . $data->id . ',id'],
    //             'phone_no' => ['required', 'string', 'unique:cmn_customers,phone_no,' . $data->id . ',id', 'max:20'],
    //             // 'street_address' => ['required', 'string']
    //         ]);
    //         if (!$validator->fails()) {
    //             //create new user
    //             $data['user_id'] = UtilityRepository::emptyToNull($data->user_id);
    //             // if ($data->user_id == 0) {
    //             //     $userId =   User::create(
    //             //         [
    //             //             'name' => $data->full_name,
    //             //             'username' => $data->phone_no,
    //             //             'password' => Hash::make('12345678'),
    //             //             // 'email' => $data->email,
    //             //             // 'email_verified_at' => Carbon::now(),
    //             //             'phone_number' => $data->phone_no,
    //             //             'is_phone_verfied' => true,
    //             //             'is_sys_adm' => 0,
    //             //             'status' => 1,
    //             //             'user_type' => UserType::WebsiteUser
    //             //         ]
    //             //     );
    //             //     $data['user_id'] = $userId->id;
    //             // } else {
    //             //     $savedUser = User::where('id', $data->user_id)->first();
    //             //     if ($savedUser != null) {
    //             //         // $savedUser->email = $data->email;
    //             //         $savedUser->name = $data->full_name;
    //             //         $savedUser->update();
    //             //     }
    //             // }
    //             $data['dob'] = UtilityRepository::emptyToNull($data->dob);
    //             CmnCustomer::where('id', $data->id)->update($data->toArray());
    //             return $this->apiResponse(['status' => '1', 'data' => ''], 200);
    //         }
    //         return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
    //     } catch (Exception $ex) {
    //         return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
    //     }
    // }

    public function customerDelete(Request $data)
    {
        try {
            // Check and delete related bookings
            $SchServiceBookingInfoIDs = SchServiceBookingInfo::where('cmn_customer_id', $data->id)->pluck('id');
            if ($SchServiceBookingInfoIDs->isNotEmpty()) {
                SchServiceBooking::whereIn('sch_service_booking_info_id', $SchServiceBookingInfoIDs)->delete();
                SchServiceBookingInfo::where('cmn_customer_id', $data->id)->delete();
            }

            // Check and delete user balance
            if (CmnUserBalance::where('user_id', $data->id)->exists()) {
                CmnUserBalance::where('user_id', $data->id)->delete();
            }
            $rtr = CmnCustomer::where('id', $data->id)->delete();
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function getAllCustomer()
    {
        $user = User::where('id', Auth()->id())->first();

        try {
            if ($user->is_sys_adm) {
                $data = CmnCustomer::select('*')
                    ->addSelect('full_name as name')
                    ->get();
            } else {
                $userBranch = SecUserBranch::where('user_id', Auth()->id())->select('cmn_branch_id')->get();
                $branIds = $userBranch->pluck('cmn_branch_id')->toArray(); // Extract branch IDs
                // All customers associated with the user's accessible branches
                $serviceBookings = SchServiceBooking::UserWiseServiceBooking()
                    ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
                    ->whereIn('sch_service_bookings.cmn_branch_id', $branIds)
                    ->get();
                // $userCustomers = CmnCustomer::select('*')->where('created_by', auth()->id())->get();

                $userCustomers = $user->customers()->get();
                $customerIds = $user->customers()->pluck('cmn_customers.id')->toArray();

                $userCustomers2 = CmnCustomer::join('manager_customer', 'manager_customer.customer_id', '=', 'cmn_customers.id')
                    ->select('manager_customer.full_name as name', 'cmn_customers.*')
                    ->whereIn('cmn_customers.id', $customerIds)
                    ->where('manager_customer.manager_id', $user->id)
                    ->orderBy('cmn_customers.id', 'DESC')
                    ->get();

                // Merge the two datasets
                $data = $serviceBookings->merge($userCustomers2);
                // Optionally remove duplicates (if needed)
                $data = $data->unique('id'); // Assumes 'id' is the unique identifier
            }
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
    public function customerStore(Request $request)
    {
        if (Auth::user()->is_sys_adm == 1) {
            $validator = Validator::make(
                $request->all(),
                [
                    'full_name' => ['required', 'string'],
                    'phone_no' => ['required', 'string', 'unique:cmn_customers,phone_no', 'max:20','regex:/^09[0-9]{8}$/'],
                ],
                [
                    'full_name.required' => 'الاسم مطلوب',
                    'phone_no.required' => 'رقم الهاتف مطلوب',
                    'phone_no.unique' => 'الرقم مسجل من قبل',
                    'phone_no.regex' => 'رقم الهاتف غير صحيح يجب أن يبدا ب 09 و يتكون من 10 رقم',
                ]
            );

            if ($validator->fails()) {
                return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
            }

            $customer = CmnCustomer::Create([
                'phone_no' => $request['phone_no'],
                'full_name' => $request['full_name'],
            ]);

            return $this->apiResponse(['status' => '1', 'data' => ['cmn_customer_id' => $customer->id]], 200);
        }

        $user = Auth::user();
        $validator = Validator::make($request->all(), [
            'full_name' => ['required', 'string'],
            'phone_no' => ['required', 'string', 'max:20','regex:/^09[0-9]{8}$/'],
        ], [
            'full_name.required' => 'الاسم مطلوب',
            'phone_no.required' => 'رقم الهاتف مطلوب',
            'phone_no.regex' => 'رقم الجوال غير صحيح يجب أن يبدا ب 09 و يتكون من 10 رقم.',
        ]);

        if ($validator->fails()) {
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        }

        $data = $request->all();

        try {
            DB::beginTransaction();

            // Check if the customer already exists
            $customer = CmnCustomer::firstOrCreate(['phone_no' => $data['phone_no']], [
                'full_name' => $data['full_name'],
            ]);
            $exists = DB::table('manager_customer')
                ->where('manager_id', $user->id)
                ->where('customer_id', $customer->id)
                ->exists();

            if (!$exists) {
                DB::table('manager_customer')->insert([
                    'full_name' => $request->full_name,
                    'manager_id' => $user->id,
                    'customer_id' => $customer->id,
                ]);
            }

            DB::commit();

            return $this->apiResponse(['status' => '1', 'data' => ['cmn_customer_id' => $customer->id]], 200);
        } catch (Exception $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
    public function customerUpdate(Request $data)
    {
        try {
            $validator = Validator::make($data->all(), [
                'full_name' => ['required', 'string'],
                'phone_no' => ['required', 'string', 'unique:cmn_customers,phone_no,' . $data->id . ',id', 'max:20'],
            ]);
            if (!$validator->fails()) {
                $data['user_id'] = UtilityRepository::emptyToNull($data->user_id);
                $data['dob'] = UtilityRepository::emptyToNull($data->dob);
                try {
                    DB::beginTransaction();
                    CmnCustomer::where('id', $data->id)->update($data->toArray());
                    DB::table('manager_customer')
                        ->where('customer_id', $data->id)
                        ->where('manager_id', auth()->id())
                        ->update(['full_name' => $data->full_name]);
                    DB::commit();
                } catch (Exception $ex) {
                    DB::rollBack();
                    return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
                }
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
}
