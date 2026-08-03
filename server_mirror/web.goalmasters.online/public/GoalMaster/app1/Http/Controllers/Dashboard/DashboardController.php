<?php

namespace App\Http\Controllers\Dashboard;

use App\Http\Controllers\Controller;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Repository\Dashboard\DashboardRepository;
use App\Models\Booking\SchServiceBooking;
use App\Models\Settings\CmnBranch;
use Carbon\Carbon;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Barryvdh\DomPDF\Facade\Pdf;
use App\Exports\BookingsExport;
use Maatwebsite\Excel\Facades\Excel;


class DashboardController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function home()
    {
        $Notifications = Auth::user()->notifications()->where('read_at', null)->latest('created_at')->take(15)->get();
        $unreadNotifications = Auth::user()->unreadNotifications();
        $unreadCount = $unreadNotifications->count();
        return view('dashboard.dashboard',compact('Notifications','unreadCount' , 'unreadNotifications'));
    }
    public function unreadCount()
    {
        $unreadCount = Auth::user()->unreadNotifications->count();
        return response()->json(['unreadCount' => $unreadCount]);
    }

    public function getDashboardCommonData(Request $request)
    {
        try {
            $dashboardRepo = new DashboardRepository();
            $rtrData = [
                'bookingStatus' => $dashboardRepo->getBookingStatus($request),
                'incomAndOtherStatistics' => $dashboardRepo->getIncomeAndOtherStatistics(),
                'topService' => $dashboardRepo->getTopServices(),
                'totalForgevin' => $dashboardRepo->getTotalForgiveness(),
            ];
            return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
        }
    }
    
    
    public function exportBookingStatusPdf(Request $request)
    {
        $br = new Controller();

        // Retrieve booking status data based on the selected date range
        $startDate = $request->input('start_date') ?? now()->toDateString();
        $endDate = $request->input('end_date') ?? now()->toDateString();
        $branchID = $request->input('branchID'); 
        $paymentMethod = $request->input('exportOption'); // Get the payment method filter
    
        // Build the initial query for the services
        $services = SchServiceBooking::UserWiseServiceBooking()
            ->with(['paymentTolerance', 'service', 'customer', 'branch', 'employee'])
            ->whereBetween('date', [$startDate, $endDate])
            ->whereIn('cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
            ->when($branchID, function($query) use ($branchID) {
                return $query->where('cmn_branch_id', $branchID);
            })
            ->when($paymentMethod == 2, function($query) {
                return $query->where('cmn_payment_type_id', 4); // Filter by online payment type
            })
            ->select([
                'id',
                'cmn_payment_type_id',
                'status',
                'cmn_customer_id',
                'cmn_branch_id',
                'sch_employee_id',
                'sch_service_id',
                'date',
                'start_time',
                'remarks',
                'paid_amount as due',
                'service_amount as total_amount',
                'online_done'
            ])
            ->orderByDesc('date')
            ->orderByDesc('start_time')
            ->get();
        $services->transform(function ($service) {
            return [
                'id' => $service->id,
                'customer' => optional($service->customer)->full_name,
                'customer_phone_no' => optional($service->customer)->phone_no,
                'branch' => optional($service->branch)->name,
                'employee' => optional($service->employee)->full_name,
                'service' => optional($service->service)->title,
                'date' => $service->date,
                'start_time' => $service->start_time,
                'end_time' => $service->end_time,
                'remarks' => $service->remarks,
                'due' => $service->due,
                'total_amount' => $service->total_amount,
                'forgiveness_amount' => optional($service->paymentTolerance)->allowed_amount ?? 0,
                'cmn_payment_type_id' => $service->cmn_payment_type_id,
                'status' => $service->status,
                'online_done' => $service->online_done,
            ];
        });
        $online = $paymentMethod == 2;
        // Return the export based on the result
        return Excel::download(new BookingsExport($services, $online), 'bookings.xlsx');
    }
    
    

    
    public function getBookingInfo(Request $request)
    {
        try {
            $dashboardRepo = new DashboardRepository();
            $rtrData = $dashboardRepo->getBookingInfo($request->serviceStatus, $request->duration);
            return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
        }
    }

    public function changeBookingStatus(Request $request)
    {
        try {
            $bookingRepo = new BookingRepository();
            $rtrData = $bookingRepo->ChangeBookingStatusAndReturnBookingData($request->id, $request->status, 1);
            return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function viewNotifications()
    {
        $notifications = Auth::user()->Notifications;
        return view('notifications', compact('notifications'));
    }

    public function markAsRead(Request $request)
    {
        $user = auth()->user();

        // Mark all unread notifications as read for the authenticated user
        $user->unreadNotifications->markAsRead();

        if ($request->expectsJson()) {
            return response()->json(['status' => 'success']);
        }

        return redirect()->back()->with('success', 'All notifications marked as read.');
    }

    public function markAsReadOne(Request $request  , $id)
    {
        try{
            $user = auth()->user();
            //? Mark unread notifications as read for the authenticated user
            $user->unreadNotifications->find($id)->markAsRead();
            if ($request->expectsJson()) {
                return response()->json(['status' => 'success']);
            }
            return response()->json(['status' => 'success', 'message' => 'All notifications marked as read.']);
        }catch (Exception $ex) {
            return back()->with('error',$ex->getMessage());
        }
    }
}
