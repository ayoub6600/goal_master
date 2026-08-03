<?php

namespace App\Http\Repository\Dashboard;

use Carbon\Carbon;
use App\Enums\ServiceStatus;
use Illuminate\Support\Facades\DB;
use App\Enums\ServicePaymentStatus;
use App\Http\Controllers\Controller;
use App\Models\Employee\SchEmployee;
use App\Models\Services\SchServices;
use Illuminate\Support\Facades\Auth;
use App\Models\Booking\SchServiceBooking;
use App\Models\Booking\BookingPaymentTolerance;
use App\Http\Repository\Settings\SettingsRepository;

class DashboardRepository
{

    public function getBookingStatus($request)
    {
        $br = new Controller();
        $today = now()->toDateString();
    
        $startDate = $request->input('start_date') ?? $today;
        $endDate = $request->input('end_date') ?? $today;
        $branchID = $request->input('branchID');
    
        $totalBooking = SchServiceBooking::UserWiseServiceBooking()
            ->whereIn('cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
            ->selectRaw('status, count(status) as serviceCount')
            ->groupBy('status')
            ->get()
            ->map(function ($item) {
                return [
                    'status' => $item->status,
                    'status_text' => ServiceStatus::getDescription($item->status),
                    'serviceCount' => $item->serviceCount,
                ];
            });
    
        $todayBooking = SchServiceBooking::UserWiseServiceBooking()
            ->whereBetween('date', [$startDate, $endDate])
            ->whereIn('cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
            ->when($branchID, fn($query) => $query->where('cmn_branch_id', $branchID))
            ->selectRaw('status, count(status) as serviceCount')
            ->groupBy('status')
            ->get()
            ->map(function ($item) {
                return [
                    'status' => $item->status,
                    'status_text' => ServiceStatus::getDescription($item->status),
                    'serviceCount' => $item->serviceCount,
                ];
            });
    
        $rtrData = [
            'totalBooking' => $totalBooking,
            'todayBooking' => $todayBooking
        ];
        return  $rtrData;
    }

    public function getIncomeAndOtherStatistics()
    {
        $br = new Controller();
        $today = new Carbon();
        $todayPaidAndDue = SchServiceBooking::UserWiseServiceBooking()
        ->whereDate('sch_service_bookings.date', $today->toDateString())
        ->whereIn('sch_service_bookings.cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
        ->whereNotIn('sch_service_bookings.status', [ServiceStatus::Processing, ServiceStatus::Cancel])
        ->selectRaw(
            'sch_service_bookings.payment_status,
            sch_service_bookings.status,
            sum(sch_service_bookings.paid_amount) as paid_amount,
            sum(sch_service_bookings.service_amount) as service_amount'
        )
        ->groupBy('sch_service_bookings.payment_status', 'sch_service_bookings.status')
        ->get();


        $todayPaidBy = SchServiceBooking::UserWiseServiceBooking()
            ->join('cmn_payment_types', 'sch_service_bookings.cmn_payment_type_id', '=', 'cmn_payment_types.id')
            ->whereIn('sch_service_bookings.cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
            ->whereNotIn('sch_service_bookings.status', [ServiceStatus::Processing , ServiceStatus::Cancel])
            ->where('sch_service_bookings.date', $today->toDateString())
            ->selectRaw(
                'cmn_payment_types.type,
            cmn_payment_types.name as PaymentBy,
            sum(sch_service_bookings.paid_amount) as paid_amount'
            )->groupBy('cmn_payment_types.name', 'cmn_payment_types.type')->get();

            $totalAllowedAmountToday = BookingPaymentTolerance::whereDate('created_at', $today->toDateString());

            if (auth()->user()->is_sys_adm != 1) {
                $totalAllowedAmountToday->where('approved_by', Auth::id());
            }
            
            $totalAllowedAmountToday = $totalAllowedAmountToday->sum('allowed_amount');
            
        return ['todayPaidAndDue' => $todayPaidAndDue, 'todayPaidBy' => $todayPaidBy, 'totalAllowedAmountToday' => $totalAllowedAmountToday];
    }

    /**
     * duration 1=today,2=last month
     * serviceStatus based on service status
     */
    public function getBookingInfo($serviceStatus, $duration)
    {
        $br = new Controller();
        $today = new Carbon();
        $today = Carbon::today();

        $services =  SchServiceBooking::UserWiseServiceBooking()
            ->join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
            ->join('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id')
            ->join('sch_employees', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
            ->whereIn('sch_service_bookings.cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'));
        if ($duration == 2) {
            $startDay = new Carbon();
            $startDay = $startDay->subDays(30);
            $services = $services->where('sch_service_bookings.date', '>=', $startDay->toDateString())
                ->where('sch_service_bookings.date', '<=', $today->toDateString());
        } else {
            $services = $services->where('sch_service_bookings.date', $today->toDateString());
        }

        if ($serviceStatus != null && $serviceStatus != "") {
            $services = $services->where('sch_service_bookings.status', '=', $serviceStatus);
        } else {
            $services = $services->where('sch_service_bookings.status', '!=', ServiceStatus::Done);
        }
        $services = $services->selectRaw(
            'sch_service_bookings.id,
            sch_service_bookings.status,
            cmn_customers.full_name as customer,
            cmn_customers.phone_no as customer_phone_no,
            cmn_branches.name as branch,
            sch_employees.full_name as employee,
            sch_services.title as service,
            sch_service_bookings.date,
            sch_service_bookings.start_time,
            sch_service_bookings.remarks,
            sch_service_bookings.service_amount-sch_service_bookings.paid_amount as due'
        )->orderByRaw('sch_service_bookings.date desc, start_time desc')->get();

        return $services;
    }

    public function getTopServices()
    {
        $br = new Controller();
        $data = SchServiceBooking::UserWiseServiceBooking()->join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->whereIn('sch_service_bookings.cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
            ->selectRaw('sch_service_id,sch_services.title,count(sch_service_bookings.sch_service_id) as service_count')
            ->groupBy('sch_service_id', 'sch_services.title')
            ->orderByRaw('service_count desc')->take(10)->get();
        return $data;
    }


    public function getTotalForgiveness()
    {
        $today = now()->toDateString();

        //? Initialize query builder
        $query = BookingPaymentTolerance::query();

        //? If the user is not a system admin, filter by approved_by
        if (auth()->user()->is_sys_adm != 1) {
            $query->where('approved_by', Auth::id());
        }

        //? Calculate daily total and total
        $total = $query->sum('allowed_amount');
        $dailyTotal = $query->whereDate('created_at', $today)->sum('allowed_amount');

        return ['dailyTotal' => $dailyTotal, 'total' => $total];
    }

    public function getCustomerWiseBookingStatus($userId)
    {
        $bookingStatus = SchServiceBooking::join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
            ->where('cmn_customers.user_id', $userId)
            ->selectRaw(
                'sch_service_bookings.status as status,
                count(*) as serviceCount'
            )->groupBy('sch_service_bookings.status')->get();

        return  $bookingStatus;
    }

    public function getLastBooking($numOfRecord, $userId)
    {
        $data =  SchServiceBooking::join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->join('sch_employees', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
            ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
            ->join('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id')
            ->where('cmn_customers.user_id', $userId)
            ->selectRaw(
                'sch_service_bookings.id,
                sch_service_bookings.status,
                sch_employees.full_name as employee,
                cmn_branches.name as branch,
                sch_services.title as service,
                sch_service_bookings.date,
                sch_service_bookings.start_time,
                sch_service_bookings.end_time,
                sch_service_bookings.remarks,
                sch_service_bookings.service_amount-sch_service_bookings.paid_amount as due'
            )->orderBy('sch_service_bookings.date', 'desc')
            ->orderBy('sch_service_bookings.start_time', 'desc')->take($numOfRecord)->get();
        return $data;
    }

    public function getAllBookingExceptDone($userId)
    {
        $data =  SchServiceBooking::join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->join('sch_employees', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
            ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
            ->join('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id')
            ->where('cmn_customers.user_id', $userId)
            ->where('sch_service_bookings.status', '!=', ServiceStatus::Done)
            ->selectRaw(
                'sch_service_bookings.id,
                sch_service_bookings.status,
                sch_employees.full_name as employee,
                cmn_branches.name as branch,
                sch_services.title as service,
                sch_service_bookings.date,
                sch_service_bookings.start_time,
                sch_service_bookings.end_time,
                sch_service_bookings.remarks,
                sch_service_bookings.service_amount-sch_service_bookings.paid_amount as due'
            )->orderBy('sch_service_bookings.date', 'desc')
            ->orderBy('sch_service_bookings.start_time', 'desc')->get();
        return $data;
    }

    public function getDoneBooking($userId)
    {
        $stRepo = new SettingsRepository();
        $currency = $stRepo->cmnCurrency();
        $data =  SchServiceBooking::join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->join('sch_employees', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
            ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
            ->join('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id')
            ->where('cmn_customers.user_id', $userId)
            ->where('sch_service_bookings.status', ServiceStatus::Done)
            ->selectRaw(
                'sch_service_bookings.id,
                sch_service_bookings.status,
                sch_employees.full_name as employee,
                cmn_branches.name as branch,
                sch_services.title as service,
                sch_service_bookings.date,
                sch_service_bookings.start_time,
                sch_service_bookings.end_time,
                sch_service_bookings.remarks,
                sch_service_bookings.service_amount-sch_service_bookings.paid_amount as due'
            )->addSelect(DB::raw("'$currency' as currency"))->orderBy('sch_service_bookings.date', 'desc')
            ->orderBy('sch_service_bookings.start_time', 'desc')->get();
        return $data;
    }

    public function getWebsiteServiceSummary()
    {
        return [
            'totalEmloyee' => SchEmployee::where('status', '!=', 3)->count(),
            'totalService' => SchServices::count(),
            'SatiffiedClient' => SchServiceBooking::selectRaw('count(*) as total')->groupBy('cmn_customer_id')->get()->count('total'),
            'DoneService' => SchServiceBooking::where('status', 4)->count()
        ];
    }
}
