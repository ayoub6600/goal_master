<?php

namespace App\Http\Controllers\Api\Booking;

use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Models\UserManagement\SecUserBranch;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Booking\BookingPaymentTolerance;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Requests\UpdateMonthlyBookingRequest;

class MonthlyBookingController extends Controller
{
    //
    private BookingRepository $bookingRepository;
	
	public function __construct(BookingRepository $bookingRepository)
    {
		$this->bookingRepository = $bookingRepository;
    }

     /**
     * @param Request $request
     * @return JsonResponse
     */
    public function updateMonthlyBooking(UpdateMonthlyBookingRequest $request)
    {
        
        DB::beginTransaction();
        try {
            $this->bookingRepository->cancelBookingMonthly($request->id, $request->service_date);
            DB::commit();

            return response()->json(['status' => '1', 'msg' => 'Success'], 200);
        } catch (Exception $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'message' => $ex->getMessage()], 400);
        }
    }

    // public function StoreMonthlyBooking($id = null)
    // {
    //       if ($id === null) {
    //           return response()->json(['status' => '500', 'msg' => 'Invalid ID'], 400);
    //       }
    //       $this->bookingRepository->StoreMonthlyBooking($id = null);
    //       return response()->json(['status' => '1', 'msg' => 'Success'], 200);
    // }
        
	
	/**
	 * @param Request $request
	 * @return JsonResponse
	 */
    public function getMonthlyBookingList(Request $request)
    {
        try {
            $branch_id = SecUserBranch::where('user_id', auth()->id())->value('cmn_branch_id');
            $data = $this->bookingRepository->getServiceBookingInfo($branch_id, 1);
            return response()->json(['status' => '1', 'data' => $data], 200);
        } catch (\Throwable $e) {
            return $this->apiResponse(['status' => '500', 'message' => $e->getMessage()], 400);
        }
    }
    

    /**
	 * @param Request $request
	 * @return JsonResponse
	 */
    public function getForgivingGenerous()
    {
        try{
            $forgivingGenerous = BookingPaymentTolerance::with([
                'booking' => function ($query) {
                    $query->select('id', 'date','start_time', 'end_time', 'cmn_branch_id' , 'cmn_customer_id','sch_employee_id' ,'sch_service_id');
                },
                'booking.branch' => function ($query) {
                    $query->select('id', 'name');
                },
                'booking.customer' => function ($query) {
                    $query->select('id', 'full_name', 'phone_no');
                },
                'booking.employee' => function ($query) {
                    $query->select('id', 'full_name');
                },
                'booking.service' => function ($query) {
                    $query->select('id', 'title','sch_service_category_id');
                },
                'booking.service.category' => function ($query) {
                    $query->select('id', 'name');
                }
            ]);
            if (auth()->user()->is_sys_adm != 1) {
                $forgivingGenerous->where('approved_by', Auth::id());
            }
            
            $forgivingGenerous = $forgivingGenerous->paginate(12);
            return response()->json([
                'status' => true,
                'data' => $forgivingGenerous->items(),
                'pagination' => [
                    'total' => $forgivingGenerous->total(),
                    'per_page' => $forgivingGenerous->perPage(),
                    'current_page' => $forgivingGenerous->currentPage(),
                    'last_page' => $forgivingGenerous->lastPage(),
                    'from' => $forgivingGenerous->firstItem(),
                    'to' => $forgivingGenerous->lastItem(),
                ]
            ], 200);
    }catch (\Throwable $e) {
        return $this->apiResponse(['status' => '500', 'message' => $e->getMessage()], 400);
    }
    }
    
    
}
