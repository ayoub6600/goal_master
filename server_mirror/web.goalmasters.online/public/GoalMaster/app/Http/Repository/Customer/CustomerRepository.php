<?php

namespace App\Http\Repository\Customer;

use App\Models\Customer\CmnCustomer;
use App\Http\Controllers\Controller;
use App\Models\Booking\SchServiceBooking;
use App\Models\User;
use App\Models\UserManagement\SecUserBranch;
use Illuminate\Support\Facades\DB;
use Exception;

class CustomerRepository
{

    // public function getCustomerDropDown(){
    //     return CmnCustomer::select('id','full_name as name','phone_no')->orderBy('id','DESC')->get();
    // }


    public function getCustomerDropDown()
    {
        $br = new Controller();
        $custo =  SchServiceBooking::select('cmn_customer_id')
            ->whereIn('sch_service_bookings.cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'));

        return CmnCustomer::select('id', 'full_name as name', 'phone_no')->whereIn('id', $custo)->orderBy('id', 'DESC')->get();
    }

    public function getCustomerDropDownplus()
    {
        $user = User::find(Auth()->id());

        if ($user->is_sys_adm) {
            // If the user is a system admin, return all customers
            return CmnCustomer::select('id', 'full_name as name', 'phone_no')
                ->orderBy('id', 'DESC')
                ->get();
        } else {
            // Get the branch IDs associated with the user
            $branchIds = SecUserBranch::where('user_id', $user->id)
                ->pluck('cmn_branch_id')
                ->toArray();

            // Fetch customers linked to the branches through service bookings
            $serviceBookingCustomerIds = SchServiceBooking::UserWiseServiceBooking()
                ->whereIn('cmn_branch_id', $branchIds)
                ->pluck('cmn_customer_id')
                ->toArray();

            // Fetch customers directly created by the user
            // $userCustomerIds = CmnCustomer::where('created_by', $user->id)->pluck('id')->toArray();
            $userCustomerIds = $user->customers()->pluck('cmn_customers.id')->toArray();

            // Combine and remove duplicate customer IDs
            $customerIds = array_unique(array_merge($serviceBookingCustomerIds, $userCustomerIds));

            // Retrieve unique customers
            $data1 = CmnCustomer::select('id', 'full_name as name', 'phone_no')
                ->whereIn('id', $customerIds)
                ->orderBy('id', 'DESC')
                ->get();

            $data2 = CmnCustomer::join('manager_customer', 'manager_customer.customer_id', '=', 'cmn_customers.id')
                ->select('manager_customer.full_name as name', 'cmn_customers.id', 'cmn_customers.phone_no')
                ->whereIn('cmn_customers.id', $customerIds)
                ->where('manager_customer.manager_id', $user->id)
                ->orderBy('cmn_customers.id', 'DESC')
                ->get();
            return $data2;
            // dd($data , $data2);
        }
    }
}
