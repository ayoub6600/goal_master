<?php

namespace App\Http\Controllers\Site;

use App\Enums\ServiceStatus;
use App\Http\Controllers\Controller;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Repository\Dashboard\DashboardRepository;
use App\Models\User as ModelsUser;
use ErrorException;
use Exception;
use Illuminate\Foundation\Auth\User;
use Illuminate\Http\Request;

class ClientDashboardController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function clientDashboard()
    {
        $dashboardRepo=new DashboardRepository();
        $customerBookingStatus=$dashboardRepo->getCustomerWiseBookingStatus(auth()->id());
        $rtrData=[
            'done'=>collect($customerBookingStatus)->where('status',ServiceStatus::Done)->sum('serviceCount'),
            'cancel'=>collect($customerBookingStatus)->where('status',ServiceStatus::Cancel)->sum('serviceCount'),
            'others'=>collect($customerBookingStatus)->whereNotIn('status',[ServiceStatus::Cancel,ServiceStatus::Done])->sum('serviceCount'),
        ];
        return view('site.client.client-dashboard',['bookingStatus'=>$rtrData]);
    }


    public function getLast10Booking()
    {
        try {
            $dashboardRepo = new DashboardRepository();
            $rtrData = $dashboardRepo->getLastBooking(10,auth()->id());
            return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex->getMessage()], 400);
        }
    }

    public function availableToCancelBooking(Request $request)
    {
       try {  
            $repo = new BookingRepository();
            $rtrData = $repo->availableToCancelBooking($request->bookingId,1,auth()->user());
            return $this->apiResponse(['status' => '1', 'data' =>$rtrData], 200);         
            
        }catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        }       
         catch (Exception $ex) {
          return  $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


}
