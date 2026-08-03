<?php

namespace App\Http\Controllers\Booking;

use App\Http\Controllers\Controller;
use App\Http\Repository\Booking\BookingRepository;
use ErrorException;
use Exception;
use Illuminate\Http\Request;

class ServiceBookingInfoController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function bookingInfo()
    {
        return view('booking.service-booking-info');
    }

    public function getServiceBookingInfo(Request $request)
    {
        try {
            $booking = new BookingRepository();
            if($request->online){
                $data = $booking->onlinePayment($request->date_from, $request->date_to ,$request->branch_id);
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            }
            $data =  $booking->getBookingInfo($request->dateFrom, $request->dateTo, $request->bookingId, $request->employeeId, $request->customerId, $request->serviceStatus , $request->branchId);
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '500', 'data' => $ex], 400);
        }
    }

    public function changeServiceBookingStatus(Request $request)
    {
        try {
            $booking = new BookingRepository();
            $data =  $booking->ChangeBookingStatus($request->booking_id, $request->status);
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
        }
    }
    
    public function addServiceBookingPayment(Request $request)
    {
        try {
            // if($request->extra_input > $request->due){return $this->apiResponse(['status' => '0', 'msg' => __("installer_messages.Invalid Request the extra_input cant be greater than due")], 400);            }
            $booking = new BookingRepository();
            $data =  $booking->addBookingPayment( $request->id, $request->due , $request->extra_input, $request->payment_status);
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex->getMessage()], 400);
        }
    }
}
