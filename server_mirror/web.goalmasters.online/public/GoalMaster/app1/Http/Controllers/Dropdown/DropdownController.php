<?php

namespace App\Http\Controllers\Dropdown;

use App\Http\Controllers\Controller;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Repository\Customer\CustomerRepository;
use App\Http\Repository\Payment\PaymentRepository;
use App\Models\Employee\SchEmployee;
use App\Models\Services\SchServiceCategory;
use App\Models\Settings\CmnBranch;
use App\Models\Settings\CmnLanguage;
use App\Models\Zone;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Foundation\Auth\User;

class DropdownController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function getServiceCategory()
    {
        try {
            $data = SchServiceCategory::select(
                'id',
                'name'
            )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getBranch()
    {
        try {
            $data = CmnBranch::UserBranches()->select(
                'id',
                'name'
            )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
    
    public function getZone()
    {
        try {
            $data = Zone::query()->select(
                'id',
                'name'
            )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getEmployee(Request $request)
    {
        try {
            $data = SchEmployee::UserEmployees();
            if ($request->branchId != "" && $request->branchId > 0)
                $data = SchEmployee::UserEmployees()->where('cmn_branch_id', $request->branchId);

            $data = $data->select(
                'id',
                'full_name as name'
            )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getCustomer()
    {
        try {
            $cust = new CustomerRepository();
            $customer = $cust->getCustomerDropDownplus();
            foreach ($customer as $val) {
                $val['name'] = $val['phone_no'] . ' - ' . $val['name'];
            }
            return $this->apiResponse(['status' => '1', 'data' => $customer], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getPaymentType()
    {
        try {
            $payment = new PaymentRepository();
            return $this->apiResponse(['status' => '1', 'data' => $payment->getPaymentTypeForBookingCalenderDropdown()], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getServiceByCategory(Request $request)
    {
        try {
            $bookingRepo = new BookingRepository();
            $data = $bookingRepo->getService($request->sch_service_category_id);
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getUsers()
    {
        try {
            $data = User::where('is_sys_adm', 0)->select('id', 'username as name')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

}
