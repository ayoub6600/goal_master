<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Repository\Dashboard\DashboardRepository;
use Exception;
use Illuminate\Http\Request;

class ClientPendingBookingController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function clientPendingBooking()
    {
      return view('site.client.client-pending-booking');
    }

    public function getPendingBooking()
    {
        try {
            $dashboardRepo = new DashboardRepository();
            $rtrData = $dashboardRepo->getAllBookingExceptDone(auth()->id());
            return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex->getMessage()], 400);
        }
    }
}
