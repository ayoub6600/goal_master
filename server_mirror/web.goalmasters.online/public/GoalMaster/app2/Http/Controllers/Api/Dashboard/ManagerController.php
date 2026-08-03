<?php

namespace App\Http\Controllers\Api\Dashboard;

use Exception;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Excel;
use App\Exports\BookingsExport;
use Maatwebsite\Excel\Exporter;
use App\Http\Controllers\Controller;
use App\Http\Requests\ExportRequest;
use App\Models\Booking\SchServiceBooking;
use App\Http\Repository\Dashboard\DashboardRepository;

class ManagerController extends Controller
{
    public function analysis(Request $request)
    {
        try {
            $dashboardRepo = new DashboardRepository();
            $rtrData = [
                'bookingStatus' => $dashboardRepo->getBookingStatus($request),
                'incomAndOtherStatistics' => $dashboardRepo->getIncomeAndOtherStatistics(),
                'topService' => $dashboardRepo->getTopServices(),
                'totalForgevin' => $dashboardRepo->getTotalForgiveness(),
            ];
            return response()->json(['status'=>'true' , 'data'=>$rtrData], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
        }
    }


    public function exportBookingStatusPdf(Request $request)
    {
        try {
            $br = new Controller();
            $startDate = now()->toDateString();
            $endDate = now()->toDateString();
            $branchID = 12;
            $paymentMethod = 1;
    
            $services = SchServiceBooking::UserWiseServiceBooking()
                ->with(['paymentTolerance', 'service', 'customer', 'branch', 'employee'])
                ->whereBetween('date', [$startDate, $endDate])
                ->whereIn('cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
                ->when($branchID, function ($query) use ($branchID) {
                    return $query->where('cmn_branch_id', $branchID);
                })
                ->when($paymentMethod == 2, function ($query) {
                    return $query->where('cmn_payment_type_id', 4);
                })
                ->select([
                    'id', 'cmn_payment_type_id', 'status', 'cmn_customer_id', 'cmn_branch_id',
                    'sch_employee_id', 'sch_service_id', 'date', 'start_time', 'remarks',
                    'paid_amount as due', 'service_amount as total_amount', 'online_done'
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
    
            // ✅ هنا بنستخدم `Excel::download()` بشكل مباشر مع API
            return Excel::download(new BookingsExport($services, $online), 'bookings.xlsx');
    
        } catch (Exception $ex) {
            return response()->json(['status' => 501, 'message' => $ex->getMessage()], 400);
        }
    }
    
    
}
