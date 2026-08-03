<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Http\Repository\Dashboard\DashboardRepository;
use Exception;
use Illuminate\Http\Request;

class ClientDoneBookingController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function clientDoneBooking()
    {
      return view('site.client.client-done-booking');
    }

    public function getDoneBooking()
    {
         try {
            $dashboardRepo = new DashboardRepository();
            $rtrData = $dashboardRepo->getDoneBooking(auth()->id());
            return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
        }
    }
}
