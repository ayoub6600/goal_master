<?php

namespace App\Http\Controllers\Api\Booking;

use Exception;
use Carbon\Carbon;
use ErrorException;
use App\Models\User;
use App\Enums\UserType;
use App\Enums\PaymentFor;
use App\Enums\PaymentType;
use App\Enums\ServiceStatus;
use Illuminate\Http\Request;
use App\Events\BookingCreated;
use App\Events\UserNotfication;
use App\Enums\ServiceVisibility;
use App\Services\WhatsAppService;
use App\Models\Settings\CmnBranch;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use App\Enums\ServicePaymentStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\FilterRequest;
use App\Models\Customer\CmnCustomer;
use App\Models\Employee\SchEmployee;
use App\Models\Services\SchServices;
use Illuminate\Support\Facades\Auth;
use App\Http\Requests\TimeSlotRequest;
use App\Notifications\UserNotification;
use App\Models\Settings\CmnBusinessHour;
use App\Enums\ServiceCancelPaymentStatus;
use App\Models\Booking\SchServiceBooking;
use Illuminate\Support\Facades\Validator;
use App\Http\Repository\UtilityRepository;
use App\Http\Requests\StoreBookingRequest;
use App\Models\Employee\SchEmployeeOffday;
use App\Http\Repository\DateTimeRepository;
use App\Http\Requests\StatusBookingRequest;
use App\Http\Requests\UpdateBookingRequest;
use App\Models\Employee\SchEmployeeService;
use App\Models\Settings\CmnBusinessHoliday;
use App\Http\Requests\BookingCanceldRequest;
use App\Http\Requests\BookingDepositRequest;
use App\Models\Employee\SchEmployeeSchedule;
use App\Models\UserManagement\SecUserBranch;
use Illuminate\Support\Facades\Notification;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Booking\BookingPaymentTolerance;
use App\Notifications\ServiceOrderNotification;
use App\Notifications\ServicelChangeStatusNotification;
use Illuminate\Pagination\LengthAwarePaginator;
use App\Http\Repository\Coupon\CouponRepository;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Repository\Payment\PaymentRepository;
use App\Models\Settings\CmnCompany;
use Symfony\Component\HttpKernel\Exception\HttpException;

class BookingController extends Controller
{

    protected $whatsAppService;

    public function __construct(WhatsAppService $whatsAppService)
    {
        $this->whatsAppService = $whatsAppService;
    }
  
      private function getDataInfo($booking_id)
    {
        $booking = SchServiceBooking::where('id', $booking_id)
            ->with('branch', 'branch.zone', 'service', 'paymentTypes', 'service.category', 'customer')
            ->first();

        if (!$booking) {
            return response()->json(['status' => 'false', 'message' => 'Booking not found'], 404);
        }

        $formattedBooking = [
            'id' => $booking->id,
            'cmn_customer_id' =>$booking->cmn_customer_id,
            'customer_name' =>optional($booking->customer)->full_name,
            'phone_number' =>optional($booking->customer)->phone_no,
            'branch' => optional($booking->branch)->name,
            'address' => optional($booking->branch)->address,
            'latitude' => optional($booking->branch)->lat,
            'longitude' => optional($booking->branch)->long,
            'date' => optional($booking->date)->format('Y-m-d'),
            'start_time' => optional($booking->start_time)->format('H:i:s'),
            'end_time' => optional($booking->end_time)->format('H:i:s'),
            'service' => optional($booking->service)->title,
            'service_amount' => $booking->service_amount,
            'paid_amount' => $booking->paid_amount,
            'payment_status' => $booking->payment_status,
            'payment_name' => ServicePaymentStatus::getDescription($booking->payment_status),
            'payment_type' => optional($booking->paymentTypes)->name,
            'status' => $booking->status,
            'status_name' => ServiceStatus::getDescription($booking->status),
            'remarks' => optional($booking->service)->remarks,
            'category' => optional($booking->service->category)->name,
        ];
        return $formattedBooking;
    }
  
  /**

    private function getDataInfo($booking_id)
    {
        $booking = SchServiceBooking::where('id', $booking_id)
            ->with('branch', 'branch.zone', 'service', 'paymentTypes', 'service.category')
            ->first();

        if (!$booking) {
            return response()->json(['status' => 'false', 'message' => 'Booking not found'], 404);
        }

        $formattedBooking = [
            'id' => $booking->id,
            'cmn_customer_id' =>$booking->cmn_customer_id,
            'branch' => optional($booking->branch)->name,
            'address' => optional($booking->branch)->address,
            'latitude' => optional($booking->branch)->lat,
            'longitude' => optional($booking->branch)->long,
            'date' => optional($booking->date)->format('Y-m-d'),
            'start_time' => optional($booking->start_time)->format('H:i:s'),
            'end_time' => optional($booking->end_time)->format('H:i:s'),
            'service' => optional($booking->service)->title,
            'service_amount' => $booking->service_amount,
            'paid_amount' => $booking->paid_amount,
            'payment_status' => $booking->payment_status,
            'payment_name' => ServicePaymentStatus::getDescription($booking->payment_status),
            'payment_type' => optional($booking->paymentTypes)->name,
            'status' => $booking->status,
            'status_name' => ServiceStatus::getDescription($booking->status),
            'remarks' => optional($booking->service)->remarks,
            'category' => optional($booking->service->category)->name,
        ];
        return $formattedBooking;
    }
**/
    private function sendBookingDetails($phoneNo, $fullName, $serviceBookingInfo ,$payment_type)
    {
        $bookingRepo = new BookingRepository();
        $bookings = $bookingRepo->getServiceInvoice($serviceBookingInfo->id)->order_details;

        foreach ($bookings as $book) {
            $book['payment_type'] = $payment_type;
            $book['web'] = 0;
            $this->whatsAppService->sendMessage($phoneNo, $fullName, $book);
        }
    }

    /**
     * ?Retrieve all bookings within the specified date and time range.
     */
    private function getBookings($booking_start, $booking_end, $start_time, $end_time, $cmn_branch_id, $category_id)
    {

        return SchServiceBooking::query()
            ->select('date', 'start_time', 'end_time', 'cmn_branch_id')
            ->when($booking_start && $booking_end, function ($query) use ($booking_start, $booking_end) {
                $query->whereBetween('date', [$booking_start, $booking_end]);
            })
            ->when($cmn_branch_id, callback: function ($query) use ($cmn_branch_id) {
                $query->where('cmn_branch_id', $cmn_branch_id);
            })
            ->when($start_time && $end_time, function ($query) use ($start_time, $end_time) {
                $query->whereBetween('start_time', [$start_time, $end_time]);
            })
            ->when($category_id, function ($query) use ($category_id) {
                $query->whereHas('service', function ($q) use ($category_id) {
                    $q->where('sch_service_category_id', $category_id);
                });
            })
            ->latest()
            ->get()
            ->groupBy('date');
    }

    /**
     * ?Retrieve field (club) information filtered by category.
     */
    private function getFields($cmn_branch_id, $category_id)
    {
        return CmnBranch::query()
            ->when($cmn_branch_id, function ($query) use ($cmn_branch_id) {
                $query->where('id', $cmn_branch_id);
            })
            ->when($category_id, function ($query) use ($category_id) {
                $query->whereHas('schServiceCategories', function ($q) use ($category_id) {
                    $q->where('id', $category_id);
                });
            })
            ->get();
    }


    /**
     * ?Generate all time slots in a 24-hour day (00:00 - 23:59).
     */
    private function generateTimeSlots()
    {
        $allHours = [];
        for ($hour = 0; $hour < 24; $hour++) {
            $start = str_pad($hour, 2, '0', STR_PAD_LEFT) . ':00:00';
            $end = str_pad($hour + 1, 2, '0', STR_PAD_LEFT) . ':00:00';
            $allHours[] = ['start_time' => $start, 'end_time' => $end];
        }
        return $allHours;
    }



    /**
     * ? Filter available time slots by excluding booked ones.
     */
 private function filterAvailableSlots($fields, $bookedSlots, $booking_start, $booking_end, $start_time = null, $end_time = null)
{
    $availableSlots = [];
    $allHours = $this->generateTimeSlots();

    // أولًا: نحول المواعيد المحجوزة إلى هيكل سهل للبحث
    $blockedSlots = [];
    foreach ($bookedSlots as $date => $slots) {
        foreach ($slots as $slot) {
            $dateStr = Carbon::parse($date)->format('Y-m-d');
            $blockedSlots[$dateStr][] = [
                'start' => Carbon::parse($slot->start_time)->format('H:i:s'),
                'end' => Carbon::parse($slot->end_time)->format('H:i:s'),
                'branch_id' => $slot->cmn_branch_id,
                'service_id' => $slot->sch_service_id
            ];
        }
    }

    foreach ($fields as $field) {
        $employees = SchEmployee::where('cmn_branch_id', $field->id)->get();
        $employeeIds = $employees->pluck('id')->toArray();
        $employeeNames = $employees->pluck('full_name')->toArray();

        for ($date = Carbon::parse($booking_start); $date->lte(Carbon::parse($booking_end)); $date->addDay()) {
            $dateStr = $date->format('Y-m-d');

            foreach ($allHours as $slot) {
                $slotStart = $slot['start_time'];
                $slotEnd = $slot['end_time'];

                // فلترة حسب الوقت المطلوب لو موجود
                if ($start_time && $end_time) {
                    if ($slotStart < $start_time || $slotEnd > $end_time) {
                        continue;
                    }
                }

                // نتحقق من كل خدمة في النادي
                foreach ($field->schServiceCategories as $category) {
                    foreach ($category->services as $service) {
                        $isBlocked = false;

                        // نتحقق إذا كان هذا الموعد محجوز لهذه الخدمة في هذا الفرع
                        if (isset($blockedSlots[$dateStr])) {
                            foreach ($blockedSlots[$dateStr] as $blocked) {
                                if ($blocked['branch_id'] == $field->id && 
                                    $blocked['service_id'] == $service->id &&
                                    $blocked['start'] == $slotStart && 
                                    $blocked['end'] == $slotEnd) {
                                    $isBlocked = true;
                                    break;
                                }
                            }
                        }

                        if (!$isBlocked) {
                            $availableSlots[] = [
                                'date' => $dateStr,
                                'start_time' => $slotStart,
                                'end_time' => $slotEnd,
                                'club_id' => $field->id,
                                'club' => $field->name,
                                'employees' => $employeeIds,
                                'employees_name' => $employeeNames,
                                'category_id' => $category->id,
                                'category_name' => $category->name,
                                'service_id' => $service->id,
                                'service_title' => $service->title,
                                'address' => $field->address,
                                'latitude' => $field->lat,
                                'longitude' => $field->long,
                            ];
                        }
                    }
                }
            }
        }
    }

    return $availableSlots;
}

    /**
     * Paginate the available slots before returning the response.
     */
    private function paginateResults($availableSlots)
    {
        $perPage = 10; // Number of results per page
        $page = request('page', 1); // Get the current page from request
        $offset = ($page - 1) * $perPage;

        // Get the sliced data based on pagination
        $paginatedData = array_slice($availableSlots, $offset, $perPage);

        // Get the actual count of items in this page
        $actualCount = count($paginatedData);

        return response()->json([
            'data' => $paginatedData,
            'current_page' => (int) $page,
            'per_page' => $actualCount, // count($paginatedData)
            'total' => count($availableSlots), // total count of items
            'last_page' => ceil(count($availableSlots) / $perPage), // count of total pages
        ]);
    }

        private function storeCustomerAsAdmin(Request $request)
    {
        return CmnCustomer::create([
            'phone_no' => $request->phone_no,
            'full_name' => $request->full_name,
        ]);
    }

    private function storeCustomerAsManager(Request $request, $user)
    {
        $customer = CmnCustomer::firstOrCreate(
            ['phone_no' => $request->phone_no],
            ['full_name' => $request->full_name]
        );

        $exists = DB::table('manager_customer')
            ->where('manager_id', $user->id)
            ->where('customer_id', $customer->id)
            ->exists();

        if (!$exists) {
            DB::table('manager_customer')->insert([
                'full_name' => $request->full_name,
                'manager_id' => $user->id,
                'customer_id' => $customer->id,
            ]);
        }

        return $customer;
    }



    /**
     * Paginate the given data and return a formatted JSON response.
     */
    public function paginateCollection(Collection $dataCollection, Request $request)
    {
        $page = max(1, $request->get('page', 1));
        $perPage = $request->get('per_page', 10);

        return new LengthAwarePaginator(
            $dataCollection->forPage($page, $perPage),
            $dataCollection->count(),
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()]
        );
    }


    public function myBookings(Request $request)
    {
        $user = Auth::guard('api')->user();
        $bookings = $user->customer->bookings()
            ->with('branch', 'branch.zone', 'service', 'paymentTypes', 'service.category')
            ->where('status', '!=', 'canceled')
            ->when($request->has('now'), function ($query) use ($request) {
                $operator = $request->boolean('now') ? '>=' : '<';
                $query->whereDate('date', $operator, now());
            })
            ->when($request->has('filter'), function ($query) use ($request) {
                $filterValue = $request->input('filter');
                if (in_array($filterValue, [0, 1, 2, 3, 4])) {
                    $query->where('status', $filterValue);
                }
            })->orderBy('id', 'desc')
            ->paginate(10);

        $bookings->getCollection()->transform(function ($booking) {
            return [
                'id' => $booking->id,
                'branch' => optional($booking->branch)->name,
                'address' => optional($booking->branch)->address,
                'latitude' => optional($booking->branch)->lat,
                'longitude' => optional($booking->branch)->long,
                'date' => optional($booking->date)->format('Y-m-d'),
                'start_time' => optional($booking->start_time)->format('H:i:s'),
                'end_time' => optional($booking->end_time)->format('H:i:s'),
                'service' => optional($booking->service)->title,
                'service_amount' => $booking->service_amount,
                'paid_amount' => $booking->paid_amount,
                'payment_status' => $booking->getPaymentStatus(),
                'payment_type' => optional($booking->paymentTypes)->name,
                'status' => $booking->status,
                'status_name' => ServiceStatus::getDescription($booking->status),
                'remarks' => optional($booking->service)->remarks,
                'category' => optional($booking->service->category)->name,
            ];
        });

        return response()->json(['status' => 'true', 'data' => $bookings], 200);
    }

    // ?todo Filter available slots for booking
    public function filterBookings(FilterRequest $request)
    {
        $validated = $request->validated();
        $booking_start = $validated['booking_start'] ?? null;
        $booking_end = $validated['booking_end'] ?? null;
        $start_time = $validated['start_time'] ?? null;
        $end_time = $validated['end_time'] ?? null;
        $cmn_branch_id = $validated['branch'] ?? null;
        $category_id = $validated['category_id'] ?? null;

        // Get all booked slots
        $bookedSlots = $this->getBookings($booking_start, $booking_end, $start_time, $end_time, $cmn_branch_id, $category_id);
       
        // Get field data
        $fields = $this->getFields($cmn_branch_id, $category_id);

        // Get available slots
        $availableSlots = $this->filterAvailableSlots($fields, $bookedSlots, $booking_start, $booking_end, $start_time, $end_time);

        // Paginate the results
        return $this->paginateResults($availableSlots);
    }

    public function getServiceTimeSlot(TimeSlotRequest $request)
    {
        try {
            $validated = $request->validated();
            $date = $validated['date'];
            $day = (new Carbon($date))->format('w');

            $employeeId = $validated['employee_id'];
            $branchId = $validated['branch_id'];
            $serviceId = $validated['service_id'];

            //? check if the employee is available
            if (SchEmployeeOffday::where('sch_employee_id', $employeeId)
                ->whereBetween('start_date', [$date, $date])
                ->exists()) {
                return $this->apiResponse(['status' => '5', 'data' => "Selected date is Staff Holiday/Leave"], 400);
            }

            //? check if the employee is off today
            if (SchEmployeeSchedule::where('sch_employee_id', $employeeId)
                ->where('day', $day)
                ->where('is_off_day', 1)
                ->exists()) {
                return $this->apiResponse(['status' => '5', 'data' => "Today is weekly holiday"], 400);
            }

            //? check if the employee is available today
            if (CmnBusinessHoliday::where('cmn_branch_id', $branchId)
                ->whereBetween('start_date', [$date, $date])
                ->exists()) {
                return $this->apiResponse(['status' => '5', 'data' => "Selected date is business holiday. Try another one."], 400);
            }

            // ? check if the employee is available today
            if (CmnBusinessHour::where('cmn_branch_id', $branchId)
                ->where('is_off_day', 1)
                ->where('day', $day)
                ->exists()) {
                return $this->apiResponse(['status' => '5', 'data' => "Selected date is a weekly holiday. Try another one."], 400);
            }

            //? retrieve employee schedule
            $schedule = SchEmployeeSchedule::where('sch_employee_id', $employeeId)
                ->where('day', $day)
                ->select('start_time', 'end_time', 'break_start_time', 'break_end_time')
                ->first();

            if (!$schedule) {
                return $this->apiResponse(['status' => '2', 'data' => 'Service is not available today'], 400);
            }

            //? retrieve employee service
            $serviceQuery = SchEmployeeService::join('sch_services', 'sch_employee_services.sch_service_id', '=', 'sch_services.id')
                ->where('sch_services.id', $serviceId)
                ->where('sch_employee_services.sch_employee_id', $employeeId);

            if (!$request->has('visibility')) {
                $serviceQuery->where('sch_services.visibility', ServiceVisibility::PublicService);
            }

            $service = $serviceQuery->select(
                'sch_services.time_slot_in_time'
            )->first();

            if (!$service) {
                return $this->apiResponse(['status' => '2', 'data' => 'Service is not available'], 400);
            }

            $timeSlotInMinute = DateTimeRepository::TotalMinuteFromTime($service->time_slot_in_time);
            $startTimeInMinute = DateTimeRepository::TotalMinuteFromTime($schedule->start_time);
            $endTimeInMinute = DateTimeRepository::TotalMinuteFromTime($schedule->end_time);

            if ($endTimeInMinute === 0) {
                return $this->apiResponse(['status' => '2', 'data' => 'Invalid working hours'], 400);
            }

            $availableServiceSlots = [];

            for ($sTime = $startTimeInMinute; $sTime <= $endTimeInMinute; $sTime += $timeSlotInMinute) {
                $serviceEndTimeInMinute = $sTime + $timeSlotInMinute;
                $availableServiceSlots[] = [
                    'start_time' => DateTimeRepository::MinuteToTime($sTime),
                    'end_time' => DateTimeRepository::MinuteToTime($serviceEndTimeInMinute),
                    'is_available' => 1
                ];
            }

            //? retrieve employee booking
            $bookingRepo = new BookingRepository();
            foreach ($availableServiceSlots as $key => $slot) {
                if ($bookingRepo->serviceIsAvaiable($serviceId, $employeeId, $date, $slot['start_time'], $slot['end_time']) > 0) {
                    $availableServiceSlots[$key]['is_available'] = 0;
                }
            }

            return $this->apiResponse(['status' => '1', 'data' => $availableServiceSlots], 200);
        } catch (Exception $e) {
            return $this->apiResponse(['status' => '403', 'data' => $e->getMessage()], 400);
        }
    }

    public function saveBooking(StoreBookingRequest $request)
    {
        $validated = $request->validated();
        $status = $validated['status'] ?? null;
        $paidAmount = is_numeric($validated['paid_amount']) ? $validated['paid_amount'] : 0;
        $employeeId = $validated['employee_id'];
        $serviceId = $validated['service_id'];
        $serviceBranchId = $validated['branch_id'];
        $is_monthly = $validated['is_monthly'] ?? 0;

        $managerID = DB::table('sec_user_branches')->where('cmn_branch_id', $serviceBranchId)->first()->user_id;
        DB::beginTransaction();
        try {

            $paymentType = $validated['payment_type'];
            $fullName = $validated['full_name'];
            $phoneNo = $validated['phone_no'];
            $state = $validated['state'];
            $postalCode = $validated['postal_code'] ?? null;
            $city = $validated['city'] ?? null;
            $streetAddress = $validated['street_address'] ?? null;
            $start_time = $validated['start_time'] ?? now('H:i:s');
            $end_time = $validated['end_time'] ?? now('H:i:s');
            $serviceDate = $validated['service_date'] ?? now('Y-m-d');
            $couponCode = $validated['coupon_code'] ?? null;

            $customerId = 0;
            $customer = null;
            if (auth()->check()) {
              
              // $customer = CmnCustomer::where('user_id', Auth::guard('api')->user()->id)->select('id', 'phone_no','user_id')->first();

                $customer = CmnCustomer::where('phone_no', $phoneNo)->first();

                if ($paymentType == PaymentType::UserBalance) {
                    $userBalance = auth()->user()->balance();
                    if ($userBalance === null) {
                        throw new ErrorException(__('messages.You do not have enough balance in your account'));
                    }
                }
            } else {
                if ($paymentType == PaymentType::UserBalance) {
                    throw new ErrorException(__('messages.You can\'t make payment by user balance without login try another one'));
                }
                $customer = CmnCustomer::where('phone_no', $phoneNo)->first();
            }
 
            if ($customer !== null) {
                $customerId = $customer->id;
            } else {
                $saveCustomer = [
                    'full_name' => $fullName,
                    'phone_no' => $phoneNo,
                    'state' => $state,
                    'postal_code' => $postalCode,
                    'city' => $city,
                    'street_address' => $streetAddress
                ];
                $cstRtrn = CmnCustomer::create($saveCustomer);
                $customerId = $cstRtrn->id;
            }

            $exists = DB::table('manager_customer')
                ->where('manager_id', $managerID)
                ->where('customer_id', $customerId)
                ->exists();

            if (!$exists) {
                DB::table('manager_customer')->insert([
                    'full_name' => $fullName,
                    'manager_id' => $managerID,
                    'customer_id' => $customerId,
                ]);
            }

            if ($customerId == 0) {
                throw new ErrorException(__('messages.Failed to save or get customer'));
            }
          
          


            $serviceList = [];
            $serviceTotalAmount = 0;

            $serviceCharge = SchEmployeeService::where('sch_employee_id', $employeeId)
                ->where('sch_service_id', $serviceId)
                ->select('fees')->first();


            $serviceStartTime = $start_time;
            $serviceEndTime = $end_time;

            if ($serviceCharge === null) {
                return response()->json(['status'=>"false" , 'data'=> __('messages.The selected service is not available at the chosen time. Please select a different time.') .
                    " [التاريخ: {$serviceDate}, من: {$serviceStartTime} إلى: {$serviceEndTime}]"],400);
            }

            $bookingRepo = new BookingRepository();
            if ($bookingRepo->serviceIsAvaiable($serviceId, $employeeId, $serviceDate, $serviceStartTime, $serviceEndTime, true) > 0) {
                return response()->json(['status'=>"false" , 'data'=>  __('messages.The selected service is not available at the chosen time. Please select a different time.') .
                    " [التاريخ: {$serviceDate}, من: {$serviceStartTime} إلى: {$serviceEndTime}]"],400);
            }


           $serviceStatus = $status 
            ?? ($paymentType === PaymentType::UserBalance 
                ? ServiceStatus::Done 
                : ServiceStatus::Processing);

            $serviceTotalAmount += $serviceCharge->fees;


            $serviceList[] = [
                'cmn_branch_id' => $serviceBranchId,
                'cmn_customer_id' => $customerId,
                'sch_employee_id' => $employeeId,
                'date' => $serviceDate,
                'start_time' => $serviceStartTime,
                'end_time' => $serviceEndTime,
                'sch_service_id' => $serviceId,
                'status' => $serviceStatus,
                'service_amount' => $serviceCharge->fees,
                'paid_amount' => $paidAmount,
                'payment_status' => ServicePaymentStatus::Unpaid,
                'cmn_payment_type_id' => $paymentType,
                'canceled_paid_amount' => 0,
                'cancel_paid_status' => ServiceCancelPaymentStatus::Unpaid,
                'remarks' => $validated['service_remarks'] ?? null,
                'created_by' => $customerId
            ];

            $payableAmount = $serviceTotalAmount;
             
            if ($paymentType == PaymentType::UserBalance) {
                $userBalance = auth()->user()->balance();
                if ($userBalance < $payableAmount) {
                    throw new ErrorException(__('messages.You do not have enough balance in your account'));
                }
            }

            $couponDiscount = 0;
            if (!empty($couponCode)) {
                $couponRepo = new CouponRepository();
                $couponDiscount = $couponRepo->validateAndGetCouponValue(auth()->id(), $couponCode, $serviceTotalAmount);
            }
            $payableAmount -= $couponDiscount;
           if($is_monthly == 1){
                return  $this->weeklyBooking($serviceList ,$paidAmount ,$paymentType,$customer,$fullName, $phoneNo);  
            }
            $serviceBookingInfo = SchServiceBookingInfo::create([
                'booking_date' => Carbon::now(),
                'cmn_customer_id' => $customerId,
                'total_amount' => $serviceTotalAmount,
                'payable_amount' => $payableAmount,
                'paid_amount' => $payableAmount,
                'due_amount' => $payableAmount,
                'is_due_paid' => 0,
                'coupon_code' => $couponCode,
                'coupon_discount' => $couponDiscount,
                'remarks' => $validated['service_remarks'] ?? null,
                'is_monthly' => 0,
				'is_monthly_active' => 0,
                'created_by' => auth()->id()
            ]);

            $serviceBookingInfo->serviceBookings()->attach($serviceList);

            DB::commit();
           if ($paymentType == PaymentType::LocalPayment) {
                // إرسال تفاصيل الحجز للعميل عبر واتساب
                $this->sendBookingDetails($phoneNo, $fullName, $serviceBookingInfo, $paymentType);

                // تحديث بيانات الدفع فقط بدون تغيير حالة الحجز (status)
                $serviceBooking = SchServiceBooking::where('sch_service_booking_info_id', $serviceBookingInfo->id)->first();
                $serviceAmount = $serviceBooking->service_amount;

                // تحديد حالة الدفع بناءً على المبلغ المدفوع
                if (auth()->user()->user_type != UserType::WebsiteUser) {
                    if ($paidAmount >= $serviceAmount) {
                        $paymentStatus = ServicePaymentStatus::Paid;
                    } elseif ($paidAmount > 0) {
                        $paymentStatus = ServicePaymentStatus::PartialPaid;
                    } else {
                        $paymentStatus = ServicePaymentStatus::Unpaid;
                    }
                } else {
                    // في حالة مستخدم الموقع، لا نسمح بدفع محلي فعليًا
                    $paymentStatus = ServicePaymentStatus::Unpaid;
                    $paidAmount = 0;
                }

                $serviceBooking->update([
                    'paid_amount'     => $paidAmount,
                    'payment_status'  => $paymentStatus,
                    // ملاحظة: لا نغير status هنا، تظل كما تم حفظها أول مرة من قيمة $status القادمة من الفلاتر
                ]);

               $branch = CmnBranch::find($serviceBranchId);
               $owner = SecUserBranch::where('cmn_branch_id',$branch->id)->first();
               $owner = User::find($owner->user_id);
               if($customer != null){
                //? todo send notification to customer 
                $user = User::where('phone_number',$customer->phone_no)->first() ?? $customer->user;
                SocketNotify($user->id, $branch->name, [
                    'msg' => __('messages.Your booking has been confirmed'),
                    'receiver' => $user->username,
                    'sender' =>  $branch->name,
                    'booking_id' => $serviceBooking,
                    'branch_id' => $branch,
                    'phone_number' => $user->phoneNo,
                    'user_type' => $user->user_type,
                    'latitude' => $branch->lat,
                    'longitude' => $branch->long,
                    'status' => ServiceStatus::Done
                ]);
                   Notification::send($user, new ServiceOrderNotification($serviceBooking, $user));
                   Notification::send(
                     auth()->user()->user_type != 1 ? $owner : auth()->user(),
                     new ServiceOrderNotification($serviceBooking, auth()->user()->user_type != 1 ? $owner : auth()->user())
                   );

                // $user->notify(new UserNotification($serviceBooking, __('messages.Your booking has been confirmed')));
                Notification::send($user, new UserNotification($serviceBooking, __('messages.Your booking has been confirmed')));
               }
                return response()->json(['status' => 'true', 'paymentType' => 'localPayment', 'data' => "Successfully saved"], 200);
            } else {
                $paymentRepo = new PaymentRepository();
                $return = $paymentRepo->makePayment($paymentType, $payableAmount, PaymentFor::ServiceCharge, $serviceBookingInfo->id);
                $returnUrl = $return['redirectUrl'] ?? null;

                if ($return['status'] != 1 ) {
                    return response()->json([
                        'status' => 'false',
                        'message' => __('messages.Payment process failed. No valid return URL.'),
                        'data' => []
                    ], 400);
                }
                $serviceBooking = SchServiceBooking::where('sch_service_booking_info_id', $serviceBookingInfo->id)->first();
                $serviceBooking->update([
                    'paid_amount' => $serviceBooking->service_amount,
                    'payment_status' => ServicePaymentStatus::Paid,
                    'status' => ServiceStatus::Done,
                ]);
              $branch = CmnBranch::find($serviceBranchId);
               if($customer != null){
                //? todo send notification to customer 
                $user = User::where('phone_number',$customer->phone_no)->first() ?? $customer->user;

                SocketNotify($user->id, $branch->name, [
                    'msg' => __('messages.Your booking has been confirmed'),
                    'receiver' => $user->username,
                    'sender' =>  $branch->name,
                    'booking_id' => $serviceBooking,
                    'branch_id' => $branch,
                    'phone_number' => $user->phoneNo,
                    'user_type' => $user->user_type,
                    'latitude' => $branch->lat,
                    'longitude' => $branch->long,
                    'status' => ServiceStatus::Done
                ]);

                // $user->notify(new UserNotification($serviceBooking, __('messages.Your booking has been confirmed')));
                Notification::send($user, new UserNotification($serviceBooking, __('messages.Your booking has been confirmed')));
               }
                $currentUserId = Auth::id();
                $userstobenotified = [];
                $users = User::where('user_type', operator: 1)->get();

                foreach ($users as $user) {
                    if ($user->id == $currentUserId) {
                        continue;
                    }
                    if ($user->is_sys_adm) {
                        $userstobenotified[] = $user;
                        SocketNotify($user->id, $branch->name, [
                            'msg' => __('messages.Your booking has been confirmed'),
                            'receiver' => $user->username,
                            'sender' =>  $branch->name,
                            'booking_id' => $serviceBooking,
                            'branch_id' => $branch,
                            'phone_number' => $user->phoneNo,
                            'user_type' => $user->user_type,
                            'latitude' => $branch->lat,
                            'longitude' => $branch->long,
                            'status' => ServiceStatus::Done
                        ]);
                        continue;
                    }
                    if ($user->sch_employee_id == $serviceId) {
                        $userstobenotified[] = $user;
                        $userstobenotified[] = Auth::guard('api')->user();
                    } elseif ($user->sch_employee_id == null) {
                        $userBranches = SecUserBranch::where('user_id', $user->id)
                            ->where('cmn_branch_id', $serviceBranchId)
                            ->exists();
                        if ($userBranches) {
                            $userstobenotified[] = $user;
                            $userstobenotified[] = Auth::guard('api')->user();
                        }
                    }
                }

                $usr = Auth::user(); // المستخدم الذي قام بالحجز
                $userstobenotified[] = $usr; // إضافة الحاجز إلى قائمة المستلمين

                $bookingss = $bookingRepo->getServiceInvoice($serviceBookingInfo->id)->order_details;

                foreach ($bookingss as $book) {
                    Notification::send($userstobenotified, new ServiceOrderNotification($book, $usr));

                    event(new BookingCreated($book, $userstobenotified, $usr));
                }


                $this->sendBookingDetails($phoneNo, $fullName, $serviceBookingInfo, $paymentType);
                return response()->json([
                    'status' => 'true',
                    'paymentType' => strtolower(PaymentType::getKey($paymentType)),
                    'data' => [
                        'serviceBookingId' => $serviceBookingInfo->id,
                        'returnUrl' => $returnUrl
                    ]
                ], 200);            }
        } catch (ErrorException $ex) {
            DB::rollBack();
            return response()->json(['status' => 'false', 'data' => $ex->getMessage()], 500);
        } catch (Exception $qx) {
            DB::rollBack();
            return response()->json(['status' => 'false', 'data' => $qx], 500);
        }
    }


    /**
     * Summary
     * update booking service from admin panel
     * Author: Kaysar
     * Date: 11-dec-2021
     */
    public function updateBooking(UpdateBookingRequest $request)
    {
        DB::beginTransaction();
        try {
            $validated = $request->validated();
            $bookingRepo = new BookingRepository();

            $serviceCharge = SchEmployeeService::where([
                'sch_employee_id' => $validated['sch_employee_id'],
                'sch_service_id' => $validated['sch_service_id']
            ])->select('fees')->first();

            if (!$serviceCharge) {
                return response()->json(['status' => 'false',  'data' => __('messages.Service not found for this employee')], 400);
            }

            [$serviceStartTime, $serviceEndTime] = explode('-', $validated['service_time']);

            if ($bookingRepo->serviceIsAvaiableApi(
                    $validated['sch_service_id'],
                    $validated['sch_employee_id'],
                    $validated['service_date'],
                    $serviceStartTime,
                    $serviceEndTime,
                    true,
                    $validated['id'],
                ) > 0 && $validated['isForceBooking'] == 0) {

                return response()->json(['status' => 'false', 'data' => __('messages.Service is not available at this time')], 200);
            }


            $serviceLimitation = $bookingRepo->IsServiceLimitation(
                $validated['service_date'],
                $serviceStartTime,
                $validated['cmn_customer_id'],
                $validated['sch_service_id'],
                1,
                1
            );

            if ($serviceLimitation['allow'] < 1 && $validated['isForceBooking'] == 0) {
                return response()->json(['status' => 'false', 'data' => $serviceLimitation['message'] . "messages.Service is not available at this time"], 200);
            }

            $paymentStatus = match (true) {
                $validated['paid_amount'] >= $serviceCharge->fees => ServicePaymentStatus::Paid,
                $validated['paid_amount'] > 0 => ServicePaymentStatus::PartialPaid,
                default => ServicePaymentStatus::Unpaid,
            };

            SchServiceBooking::where('id', $validated['id'])->update([
                'cmn_branch_id' => $validated['cmn_branch_id'],
                'cmn_customer_id' => $validated['cmn_customer_id'],
                'sch_employee_id' => $validated['sch_employee_id'],
                'date' => $validated['service_date'],
                'start_time' => $serviceStartTime,
                'end_time' => $serviceEndTime,
                'sch_service_id' => $validated['sch_service_id'],
                'status' => $validated['status'],
                'service_amount' => $serviceCharge->fees,
                'paid_amount' => $validated['paid_amount'],
                'payment_status' => $paymentStatus,
                'cmn_payment_type_id' => $validated['cmn_payment_type_id'],
                'canceled_paid_amount' => 0,
                'cancel_paid_status' => ServiceCancelPaymentStatus::Unpaid,
                'remarks' => $validated['remarks'],
                'updated_by' => auth()->id(),
            ]);

            DB::commit();

            $bookingData = $bookingRepo->getEmployeeBookingSchedule(
                $validated['cmn_branch_id'],
                $validated['sch_employee_id'],
                0,
                null,
                $validated['id']
            );

            return response()->json(['status' => 'true', 'data' => $bookingData], 200);
        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json(['status' => 'false', 'data' => $e->getMessage()], 400);
        }
    }


    /**
     * Summary
     * cancel booking service from admin panel
     * Author: Kaysar
     * Date: 11-dec-2021
     */
     public function cancelBooking(BookingCanceldRequest $request)
    {
        try {
            $validated = $request->validated();
            $bookingRepo = new BookingRepository();
            $booking = SchServiceBooking::find($validated['id']);
            $userBranch = SecUserBranch::where('cmn_branch_id', $booking->cmn_branch_id)->first();
            $user = User::find($userBranch->user_id);
            Notification::send($user, new ServiceOrderNotification($booking, $user));
            return response()->json(['status' => 'true', 'data' => $bookingRepo->ChangeBookingStatusAndReturnBookingData($validated['id'], ServiceStatus::Cancel)], 200);
        } catch (ErrorException $ex) {
            return response()->json(['status' => 'false', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return response()->json(['status' => 'false', 'data' => $qx], 400);
        }
    }

    public function getServiceBookingInfo(Request $request)
    {
        try {
            $user = Auth::guard('api')->user();
            $booking = new BookingRepository();

            if ($request->online) {
                $data = $booking->onlinePayment(
                    $request->date_from,
                    $request->date_to,
                    $request->branch_id ?? $user->branches->first()->cmn_branch_id
                );
            } else {
                $data = $booking->getBookingInfo(
                    $request['dateFrom'],
                    $request['dateTo'],
                    $request['bookingId'],
                    $request['employeeId'],
                    $request['customerId'],
                    $request['serviceStatus'],
                    $request['branchId'],
                );
            }

            $dataCollection = collect($data)->sortByDesc('id')->values();
            $paginatedData = $this->paginateCollection($dataCollection, $request);

            return response()->json([
                'status' => 'true',
                'data' => $paginatedData
            ], 200);

        } catch (Exception $ex) {
            return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 400);
        }
    }

    public function changeServiceBookingStatus(StatusBookingRequest $request)
    {
        try {
            $validated = $request->validated();
            $bookingRepo = new BookingRepository();
            $bookingRepo->ChangeBookingStatus($validated['booking_id'], $validated['status']);
            $formattedBooking = $this->getDataInfo($validated['booking_id']);
            $user = User::where('phone_number',$formattedBooking['phone_number'])->first() ;
            $booking = SchServiceBooking::find($validated['booking_id']);
            $message = $this->messageBookingStatus($booking->status,$booking->branch->name);
            Notification::send($user, new ServicelChangeStatusNotification($booking, $user,$message));
            return response()->json(['status' => 'true' , 'message' => __('messages.Booking status changed successfully') , 'data' => $formattedBooking], 200);

        } catch (ErrorException | Exception $ex) {
            return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 400);
        }
    }
    public function messageBookingStatus($status, $nameBanch)
    {
        try {
            $messages = [
                2 => "تم قبول طلبك من {$nameBanch}",
                3 => "تم رفض طلبك من {$nameBanch}",
                4 => "تم قبول طلبك من {$nameBanch}",
            ];

            return $messages[$status] ?? "حالة غير معروفة من {$nameBanch}";
        } catch (\Exception $e) {
            return "حصل خطأ في معالجة الحالة.";
        }
    }


    public function getBookingInfo(Request $request)
    {
        try{
            $id = $request->input('id');
            if (!$id) {return response()->json(['status' => false,'errors' => [['id' => __('messages.id is required')]]], 400); }
            $formattedBooking = $this->getDataInfo($id);
            if(auth()->user()->user_type == UserType::WebsiteUser && $formattedBooking['cmn_customer_id'] != auth()->user()->customer->id){
                return response()->json(['status' => 'false', 'message' => __('messages.You are not authorized to view this booking')], 403);
            }
            return response()->json(['status' => 'true'  , 'data' => $formattedBooking , 'message' => __('messages.Booking data fetched successfully')], 200);
        }catch(Exception $ex){
            return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 400);
        }
    }



    public function addServiceBookingPayment(BookingDepositRequest $request)
    {
        try {
            $validated = $request->validated();
            $booking = new BookingRepository();
            $booking->addBookingPayment( $validated['booking_id'], $validated['due'] , $validated['extra_input'] ?? null, $validated['payment_status']);
            $formattedBooking = $this->getDataInfo($validated['booking_id']);

            return response()->json(['status' => 'true', 'data' => $formattedBooking], 200);
        } catch (ErrorException $ex) {
            return response()->json(['status' => 'false', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            return response()->json(['status' => 'false', 'data' => $ex->getMessage()], 400);
        }
    }

    //getServiceInfo
        public function getServiceList()
    {
        try {
            $services = SchServices::with(['category' => function ($query) {
                $query->select('id', 'name', 'cmn_branch_id');
            }])
                ->select([
                    'id',
                    'title',
                    'sch_service_category_id',
                    'visibility',
                    'price',
                    'duration_in_days',
                    'duration_in_time',
                    'time_slot_in_time',
                    'padding_time_before',
                    'padding_time_after',
                    'appoinntment_limit_type',
                    'appoinntment_limit',
                    'minimum_time_required_to_booking_in_days',
                    'minimum_time_required_to_booking_in_time',
                    'minimum_time_required_to_cancel_in_days',
                    'minimum_time_required_to_cancel_in_time',
                    'remarks',
                    'created_at'
                ])
                ->latest('created_at')
                ->get();

            $data = $services->map(function ($service) {
                return [
                    'id' => $service->id,
                    'category' => $service->category->name ?? '',
                    'title' => $service->title,
                    'image_url' => $service->getFirstMediaUrl('services') ?: asset('img/ball.png'),
                    'sch_service_category_id' => $service->sch_service_category_id,
                    'visibility' => $service->visibility,
                    'price' => $service->price,
                    'duration_in_days' => $service->duration_in_days,
                    'duration_in_time' => $service->duration_in_time,
                    'time_slot_in_time' => $service->time_slot_in_time,
                    'padding_time_before' => $service->padding_time_before,
                    'padding_time_after' => $service->padding_time_after,
                    'appoinntment_limit_type' => $service->appoinntment_limit_type,
                    'appoinntment_limit' => $service->appoinntment_limit,
                    'minimum_time_required_to_booking_in_days' => $service->minimum_time_required_to_booking_in_days,
                    'minimum_time_required_to_booking_in_time' => $service->minimum_time_required_to_booking_in_time,
                    'minimum_time_required_to_cancel_in_days' => $service->minimum_time_required_to_cancel_in_days,
                    'minimum_time_required_to_cancel_in_time' => $service->minimum_time_required_to_cancel_in_time,
                    'remarks' => $service->remarks,
                    'branch_id' => $service->category->cmn_branch_id ?? null,
                ];
            });

            return $this->apiResponse([
                'status' => 'success',
                'data' => $data
            ], 200);

        } catch (\Exception $e) {
            \Log::error('Service List Error: ' . $e->getMessage());
            return $this->apiResponse([
                'status' => 'error',
                'message' => __('Failed to retrieve service list')
            ], 500);
        }
    }



    public function returnCustomers(Request $request)
    {
        try{
            $user = Auth::user();
            $search = $request->query('search');
            if ($user->is_sys_adm == UserType::SystemAdmin) {
                // If the user is an admin, show all customers
                $allcustomers = DB::table('cmn_customers')
                    ->when($search, function ($query) use ($search) {
                        return $query->where(function($q) use ($search) {
                            $q->where('full_name', 'LIKE', "%{$search}%")
                            ->orWhere('phone_no', 'LIKE', "%{$search}%");
                        });
                    })
                    ->get();
            } else {
                // If the user is not an admin, limit to their accessible branches
                $userBranch = SecUserBranch::where('user_id', $user->id)
                                ->pluck('cmn_branch_id')
                                ->toArray();

                $allcustomers = SchServiceBooking::UserWiseServiceBooking()
                    ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
                    ->whereIn('sch_service_bookings.cmn_branch_id', $userBranch)
                    ->when($search, function ($query) use ($search) {
                        return $query->where(function($q) use ($search) {
                            $q->where('cmn_customers.full_name', 'LIKE', "%{$search}%")
                            ->orWhere('cmn_customers.phone_no', 'LIKE', "%{$search}%");
                        });
                    })
                    ->select('cmn_customers.*') // return only customer fields
                    ->distinct()
                    ->get();
            }

            return $allcustomers;
        }catch (Exception $ex) {
                return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 400);
            }

    }

    
    // ?todo customer store 
    public function customerStore(Request $request)
    {
        $user = Auth::user();
        $isAdmin = $user->is_sys_adm == 1;

        $validator = $this->validateCustomer($request, $isAdmin);

        if ($validator->fails()) {
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        }

        try {
            DB::beginTransaction();

            $customer = $isAdmin
                ? $this->storeCustomerAsAdmin($request)
                : $this->storeCustomerAsManager($request, $user);

            DB::commit();
            return $this->apiResponse(['status' => '1', 'data' => ['cmn_customer_id' => $customer->id]], 200);

        } catch (\Exception $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'data' => ['message' => $ex->getMessage()]], 400);
        }
    }


    private function validateCustomer(Request $request, bool $isAdmin)
    {
        $rules = [
            'full_name' => ['required', 'string'],
            'phone_no' => ['required', 'string', 'max:20', 'regex:/^09[0-9]{8}$/'],
        ];

        $messages = [
            'full_name.required' => 'الاسم مطلوب',
            'phone_no.required' => 'رقم الهاتف مطلوب',
            'phone_no.regex' => 'رقم الهاتف غير صحيح يجب أن يبدا ب 09 و يتكون من 10 رقم',
        ];

        if ($isAdmin) {
            $rules['phone_no'][] = 'unique:cmn_customers,phone_no';
            $messages['phone_no.unique'] = 'الرقم مسجل من قبل';
        }

        return Validator::make($request->all(), $rules, $messages);
    }
  
  
  
  
  
  
      private function notifyBooking(SchServiceBookingInfo $bookingInfo, $paymentType, $customer, $phoneNo, $fullName)
    {
        $serviceBooking = SchServiceBooking::where('sch_service_booking_info_id', $bookingInfo->id)->first();
        $branch = CmnBranch::find($serviceBooking->cmn_branch_id ?? $bookingInfo->branch_id ?? null);
        $user = User::where('phone_number', $customer->phone_no)->first() ?? $customer->user;
        $authUser = Auth::user();

        // 1. Send socket
        if ($user) {
            SocketNotify($user->id, $branch->name ?? 'Branch', [
                'msg' => __('messages.Your booking has been confirmed'),
                'receiver' => $user->username,
                'sender' => $branch->name ?? 'Branch',
                'booking_id' => $serviceBooking,
                'branch_id' => $branch,
                'phone_number' => $user->phoneNo,
                'user_type' => $user->user_type,
                'latitude' => $branch->lat ?? '',
                'longitude' => $branch->long ?? '',
                'status' => $serviceBooking->status,
            ]);
        }

        // 2. Notification to user
        Notification::send($user, new UserNotification($serviceBooking, __('messages.Your booking has been confirmed')));
        Notification::send($authUser, new ServiceOrderNotification($serviceBooking, $authUser));

        // 3. WhatsApp message
        $this->sendBookingDetails($phoneNo, $fullName, $bookingInfo, $paymentType);

        // 4. Notify admins (only for Online Payment, or pass flag)
        $userstobenotified = [];
        $users = User::where('user_type', operator: 1)->get();
        foreach ($users as $admin) {
            if ($admin->is_sys_adm || $admin->sch_employee_id == $serviceBooking->sch_employee_id) {
                $userstobenotified[] = $admin;
            }
        }

        $userstobenotified[] = $authUser;

        $bookings = app(BookingRepository::class)->getServiceInvoice($bookingInfo->id)->order_details;
        foreach ($bookings as $book) {
            Notification::send($userstobenotified, new ServiceOrderNotification($book, $authUser));
            event(new BookingCreated($book, $userstobenotified, $authUser));
        }
    }
  
  
  public function weeklyBooking(array $serviceList, float $payableAmount, int $paymentType, CmnCustomer $customer, string $fullName, string $phoneNo)
{
    DB::beginTransaction();
    try {
        $totalAmount = $serviceList[0]['service_amount'];
        $customerId = $serviceList[0]['cmn_customer_id'];
        $serviceDate = $serviceList[0]['date']; // أول يوم
        $couponCode = $serviceList[0]['coupon_code'] ?? null;
        $couponDiscount = $serviceList[0]['coupon_discount'] ?? 0;
        $remarks = $serviceList['remarks'] ?? null;

        $allBookings = [];
        $bookingDates = [];

        // نحسب عدد المرات (4 أو 5) حسب عدد الأسابيع الباقية في الشهر
        $startDate = Carbon::parse($serviceDate);
        $endOfMonth = $startDate->copy()->endOfMonth();
        $weeksCount = ceil($startDate->diffInDays($endOfMonth) / 7) + 1;
       
        // 1. Check for conflicts first
        for ($i = 0; $i < $weeksCount; $i++) { 
          $serviceDateForWeek = $startDate->copy()->addWeeks($i)->format('Y-m-d');
          $conflict = SchServiceBookingInfo::whereHas('serviceBookinges', function ($query) use ($serviceDateForWeek, $serviceList) {
                      $query->whereDate('date', $serviceDateForWeek)
                            ->where('sch_service_id', $serviceList[0]['sch_service_id'])
                            ->where(function ($q) use ($serviceList) {
                                  $q->whereBetween('start_time', [$serviceList[0]['start_time'], $serviceList[0]['end_time']])
                                    ->orWhereBetween('end_time', [$serviceList[0]['start_time'], $serviceList[0]['end_time']])
                                    ->orWhere(function ($q2) use ($serviceList) {
                                        $q2->where('start_time', '<=', $serviceList[0]['start_time'])
                                           ->where('end_time', '>=', $serviceList[0]['end_time']);
                                    });
                            });
                  })
                  ->where(function ($q) {
                      $q->where(function ($q2) {
                          $q2->where('is_monthly', 1)
                             ->where('is_monthly_active', 1);
                      })
                      ->orWhere('is_monthly', 0);
                  })
                  ->exists();


            if ($conflict) {
                DB::rollBack();
                return response()->json([
                    'status' => false,
                    'msg' => "يوجد تعارض في الحجز يوم {$serviceDateForWeek} من الساعة {$serviceList[0]['start_time']} إلى {$serviceList[0]['end_time']}",
                ], 422);
            }

            $bookingDates[] = $serviceDateForWeek;
        }

        // 2. لو مفيش أي تعارض، نعمل Create للحجوزات كلها
        foreach ($bookingDates as $index => $date) {
            $currentPaid = 0;
            if ($payableAmount >= $totalAmount) {
                $currentPaid = $totalAmount;
                $payableAmount -= $totalAmount;
            } elseif ($payableAmount > 0) {
                $currentPaid = $payableAmount;
                $payableAmount = 0;
            }

            $service = $serviceList;
            $service[0]['date'] = $date;
            $service[0]['paid_amount'] = $currentPaid;
            $service[0]['payment_status'] = match (true) {
                $currentPaid >= $totalAmount => ServicePaymentStatus::Paid,
                $currentPaid > 0 => ServicePaymentStatus::PartialPaid,
                default => ServicePaymentStatus::Unpaid,
            };
            $service[0]['status'] = match (true) {
                $currentPaid >= $totalAmount => ServiceStatus::Done,
                $currentPaid >= 0 => ServiceStatus::Approved,
                default => ServiceStatus::Pending,
            };

            $serviceBookingInfo = SchServiceBookingInfo::create([
                'booking_date' => $date,
                'cmn_customer_id' => $customerId,
                'total_amount' => $totalAmount,
                'payable_amount' => $totalAmount,
                'paid_amount' => $currentPaid,
                'due_amount' => $totalAmount - $currentPaid,
                'is_due_paid' => 0,
                'coupon_code' => $couponCode,
                'coupon_discount' => $couponDiscount,
                'remarks' => $remarks,
                'is_monthly' => 1,
                'is_monthly_active' => $index === 0 ? 1 : 0,
                'created_by' => auth()->id()
            ]);

            $serviceBookingInfo->serviceBookings()->attach([$service[0]]);
            $allBookings[] = $serviceBookingInfo->load('serviceBookinges');

            $this->notifyBooking($serviceBookingInfo, $paymentType, $customer, $phoneNo, $fullName);
        }

        DB::commit();

        $html = view('reports.invoice', [
            'orders' => $allBookings,
            'customer' => $customer,
            'phoneNo' => $phoneNo,
            'fullName' => $fullName,
            'company_info' => CmnCompany::first(),
        ])->render();

        return response()->json([
            'status' => true,
            'html' => $html,
            'msg' => "تم الحجز بنجاح :)...!"
        ]);

    } catch (Exception $e) {
        DB::rollBack();
        return response()->json(['status' => false, 'msg' => $e->getMessage()], 500);
    }
}

  
/**
public function weeklyBooking(array $serviceList, float $payableAmount, int $paymentType, CmnCustomer $customer, string $fullName, string $phoneNo)
{
    try {
        $totalAmount = $serviceList[0]['service_amount'];
        $customerId = $serviceList[0]['cmn_customer_id'];
        $serviceDate = $serviceList[0]['date'];
        $couponCode = $serviceList[0]['coupon_code'] ?? null;
        $couponDiscount = $serviceList[0]['coupon_discount'] ?? 0;

        $allBookings = [];

        for ($i = 0; $i < 4; $i++) {
            $currentPaid = 0;
            if ($payableAmount >= $totalAmount) {
                $currentPaid = $totalAmount;
                $payableAmount -= $totalAmount;
            } elseif ($payableAmount > 0) {
                $currentPaid = $payableAmount;
                $payableAmount = 0;
            }

            $serviceDateForWeek = Carbon::parse($serviceDate)->addWeeks($i)->format('Y-m-d');

            $service = $serviceList;
            $service[0]['date'] = $serviceDateForWeek;
            $service[0]['paid_amount'] = $currentPaid;
            $service[0]['payment_status'] = match (true) {
                $currentPaid >= $totalAmount => ServicePaymentStatus::Paid,
                $currentPaid > 0 => ServicePaymentStatus::PartialPaid,
                default => ServicePaymentStatus::Unpaid,
            };
            $service[0]['status'] = match (true) {
                      $currentPaid >= $totalAmount => ServiceStatus::Done,
                      $currentPaid >= 0 => ServiceStatus::Approved,
                      default => ServiceStatus::Pending,
                  };//$currentPaid >= $totalAmount ? ServiceStatus::Done : ServiceStatus::Processing;

            $serviceBookingInfo = SchServiceBookingInfo::create([
                'booking_date' => Carbon::now(),
                'cmn_customer_id' => $customerId,
                'total_amount' => $totalAmount,
                'payable_amount' => $totalAmount,
                'paid_amount' => $currentPaid,
                'due_amount' => $totalAmount - $currentPaid,
                'is_due_paid' => 0,
                'coupon_code' => $couponCode,
                'coupon_discount' => $couponDiscount,
                'remarks' => $serviceList['remarks'] ?? null,
                'is_monthly' => 1,
                'is_monthly_active' => $i === 0 ? 1 : 0,
                'created_by' => auth()->id()
            ]);

            $serviceBookingInfo->serviceBookings()->attach([$service[0]]);
            DB::commit();

            $allBookings[] = $serviceBookingInfo->load('serviceBookinges');
            $this->notifyBooking($serviceBookingInfo, $paymentType, $customer, $phoneNo, $fullName);
        }

        $html = view('reports.invoice', [
            'orders' => $allBookings,
            'customer' => $customer,
            'phoneNo' => $phoneNo,
            'fullName' => $fullName,
            'company_info' => CmnCompany::first(), // عدلها حسب شركتك
        ])->render();

        return response()->json([
            'status' => true,
            'html' => $html,
            'msg' => "Save Succefully :)...!"
        ]);

    } catch (Exception $e) {
        return response()->json(['status' => 'false', 'data' => $e->getMessage()], 500);
    }
}

**/




}    