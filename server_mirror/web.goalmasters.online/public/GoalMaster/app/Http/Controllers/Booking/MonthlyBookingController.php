<?php

namespace App\Http\Controllers\Booking;

use App\Http\Controllers\Controller;
use App\Http\Repository\Booking\BookingRepository;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Models\Services\SchServiceCategory;
use App\Models\User;
use App\Models\UserManagement\SecUserBranch;
use App\Models\Settings\CmnBranch;
use Exception;
use Illuminate\Queue\QueueManager;
use Illuminate\Validation\Rule;

class MonthlyBookingController extends Controller
{
	
	private BookingRepository $bookingRepository;
	
	public function __construct(BookingRepository $bookingRepository)
    {
        $this->middleware('auth');
		$this->bookingRepository = $bookingRepository;
    }

    public function MonthlyBooking()
    {
        return view('booking.monthly-booking');
    }

    public function forgivingGenerous()
    {
        return view('booking.forgiving-generous');
    }


    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function updateMonthlyBooking(Request $request)
    {
    	DB::beginTransaction();
        try {
            $validator = Validator::make($request->toArray(), [
                'service_date' => ['required', 'date', 'after_or_equal:today'],
                'id' => ['required', 'integer'],
            ]);
          
            if (!$validator->fails()) {
            	$this->bookingRepository->cancelBookingMonthly($request->id, $request->service_date);
            	DB::commit();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            DB::rollBack();
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
			DB::rollBack();
			throw $ex;
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
	
	/**
	 * @param Request $request
	 * @return JsonResponse
	 */
    public function getMonthlyBookingList(Request $request): JsonResponse
    {
        try {
            $branch_id = SecUserBranch::where('user_id', auth()->id())->value('cmn_branch_id');
            $data = $this->bookingRepository->getServiceBookingInfo($branch_id, 1);
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (\Throwable $e) {
            return $this->apiResponse(['status' => '403', 'message' => $e->getMessage()], 400);
        }
    }
    

    /**
	 * @param Request $request
	 * @return JsonResponse
	 */
    public function getForgivingGenerousList(Request $request): JsonResponse
	{
		try {
			$data = $this->bookingRepository->getForgivingGenerous();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
		} catch (Exception $qx) {
			return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
		}
    }
}
