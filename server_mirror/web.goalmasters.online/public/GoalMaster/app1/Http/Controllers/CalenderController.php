<?php

namespace App\Http\Controllers;

use App\Models\Booking\SchServiceBooking;
use App\Models\User;
use App\Models\UserManagement\SecUserBranch;
use App\Models\Settings\CmnBranch;
use App\Http\Controllers\Controller;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Exception;
use Carbon\Carbon;

class CalenderController extends Controller
{



  public function viewCalender(Request $request)
  {

    $branchId = $request->input('branch_id');
    $selectedBranch = $branchId;

    $branches = DB::table('cmn_branches')->get();

    $date = $request->input('date') ?? Carbon::now()->toDateString();

    $categoryId = $request->input('category_id');
    $selectedCategory = $categoryId;
    $categories = $branchId ? DB::table('sch_service_categories')->where('cmn_branch_id', $branchId)->get() : [];

    $allcustomers = DB::table('cmn_customers')->get();
    $customerSearch = $request->input('customer_search');
    $customers = DB::table('cmn_customers')
      ->when($customerSearch, function ($query) use ($customerSearch) {
        return $query->where('full_name', 'LIKE', "%{$customerSearch}%");
      })
      ->get();
    $customerId = $request->input('customer_id');
    $selectedCustomer = $customerId;
    $bookingServiceId = $request->input('bookingServiceId');



    $isAllBranch = true;
    if (Auth()->id()) {

      $user = User::where('id', Auth()->id())->first();
      $userType = $user->user_type;
      if (!($user->is_sys_adm || $userType  == 2)) {
        $isAllBranch = false;
      }
    }
    if ($isAllBranch) {
      // If the user is an admin, show all branches
      $branches = DB::table('cmn_branches')->get();
      $categories = $branchId ? DB::table('sch_service_categories')->where('cmn_branch_id', $branchId)->get() : [];
      $allcustomers = DB::table('cmn_customers')->get();
    } else {
      // If the user is not an admin, limit to their accessible branches
      $userBranch = SecUserBranch::where('user_id', Auth()->id())->select('cmn_branch_id')->get();
      $branIds = $userBranch->pluck('cmn_branch_id')->toArray(); // Extract branch IDs

      $branches = DB::table('cmn_branches')
        ->whereIn('id', $branIds)
        ->get();

      $categories = DB::table('sch_service_categories')
        ->whereIn('cmn_branch_id', $branIds)
        ->get();

      // All customers associated with the user's accessible branches
      $allcustomers = SchServiceBooking::UserWiseServiceBooking()
        ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
        ->whereIn('sch_service_bookings.cmn_branch_id', $branIds)
        ->get();

      // Default to user's accessible branches if branchId is null
      if (is_null($branchId)) {
        $branchId = $branIds;
      }

      if (is_null($categoryId)) {
        $categoryId = $categories->pluck('id')->toArray();
      }
    }

    // Ensure branchId and categoryId are arrays
    $branchId = is_array($branchId) ? $branchId : ($branchId ? [$branchId] : []);
    $categoryId = is_array($categoryId) ? $categoryId : ($categoryId ? [$categoryId] : []);
    $customerId = is_array($customerId) ? $customerId : ($customerId ? [$customerId] : []);
    // Fetch services with pagination
    $services = DB::table('sch_services')
      ->join('sch_service_categories', 'sch_services.sch_service_category_id', '=', 'sch_service_categories.id')
      ->join('cmn_branches', 'sch_service_categories.cmn_branch_id', '=', 'cmn_branches.id')
      ->when($categoryId, fn($query) => $query->whereIn('sch_services.sch_service_category_id', $categoryId))
      ->when($branchId, fn($query) => $query->whereIn('cmn_branches.id', $branchId))
      ->select(
        'sch_services.*',
        'sch_service_categories.id as category_id',
        'cmn_branches.id as cmn_branch_id',
      )
      ->paginate(3);


    // Fetch booked services for the selected date with pagination
    $br = new Controller();

    $bookingService = SchServiceBooking::UserWiseServiceBooking()
      ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
      ->join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
      // ->whereIn('sch_service_bookings.cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
      ->where('sch_service_bookings.date', $date)
      ->when($customerId, fn($query) => $query->whereIn('sch_service_bookings.cmn_customer_id', $customerId))
      ->when($bookingServiceId, fn($query) => $query->where('sch_service_bookings.id', $bookingServiceId))
      // ->when($branchId, fn($query) => $query->whereIn('sch_service_bookings.cmn_branch_id', $branchId))
      ->select(
        'sch_service_bookings.sch_employee_id',
        'sch_service_bookings.id',
        'cmn_customers.full_name as customer',
        'sch_service_bookings.date',
        'sch_service_bookings.start_time',
        'sch_service_bookings.end_time',
        'sch_services.title as service',
        'sch_service_bookings.status'
      )
      ->get();

    return view('calendar', [
      'branches' => $branches,
      'selectedBranch' => $selectedBranch,
      'data' => $services,
      'categories' => $categories,
      'allcustomers' => $allcustomers,
      'customer_id' => $customerId,
      'customers' => $customers,
      'selectedCategory' => $selectedCategory,
      'bookingService' => $bookingService,
      'bookingServiceId' => $bookingServiceId,
    ]);
  }



  public function getBookingInfoByServiceId(Request $request)
  {
    try {
      $bookingService = SchServiceBooking::join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
        ->join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
        ->join('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id')
        ->join('sch_employees', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
        ->where('sch_service_bookings.id', $request->sch_service_booking_id)
        ->select(
          'sch_service_bookings.id',
          'cmn_branches.name as branch',
          'sch_service_bookings.cmn_branch_id',
          'sch_employees.full_name as employee',
          'sch_service_bookings.sch_employee_id',
          'cmn_customers.full_name as customer',
          'sch_service_bookings.cmn_customer_id',
          'cmn_customers.phone_no',
          // 'cmn_customers.email',
          'sch_service_bookings.date',
          'sch_service_bookings.sch_service_id',
          'sch_services.title as service',
          'sch_services.sch_service_category_id',
          'sch_service_bookings.start_time',
          'sch_service_bookings.end_time',
          'sch_service_bookings.paid_amount',
          'sch_service_bookings.status',
          'sch_service_bookings.remarks',
          'sch_service_bookings.created_at',
          'sch_service_bookings.cmn_payment_type_id',
          'sch_service_bookings.remarks',
          'sch_employees.specialist',
          'sch_employees.image_url'
        )->first();
      return $this->apiResponse(['status' => '1', 'data' => $bookingService], 200);
    } catch (Exception $ex) {
      return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
    }
  }
}
