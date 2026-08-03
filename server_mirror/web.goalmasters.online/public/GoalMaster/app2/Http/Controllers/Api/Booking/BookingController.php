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
use Illuminate\Support\Facades\Auth;
use App\Http\Requests\TimeSlotRequest;
use App\Notifications\UserNotification;
use App\Models\Settings\CmnBusinessHour;
use App\Enums\ServiceCancelPaymentStatus;
use App\Models\Booking\SchServiceBooking;
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
use Illuminate\Pagination\LengthAwarePaginator;
use App\Http\Repository\Coupon\CouponRepository;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Repository\Payment\PaymentRepository;

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
    private function filterAvailableSlots($fields, $bookedSlots, $booking_start, $booking_end, $start_time, $end_time)
    {
        $availableSlots = [];
        $allHours = $this->generateTimeSlots();

        foreach ($fields as $field) {
            for ($date = Carbon::parse($booking_start); $date->lte(Carbon::parse($booking_end)); $date->addDay()) {
                $dateStr = $date->format('Y-m-d');

                $hasBookingsInPeriod = isset($bookedSlots[$dateStr]) && $bookedSlots[$dateStr]->contains(function ($booking) use ($start_time, $end_time) {
                        return ($booking->start_time >= $start_time && $booking->start_time < $end_time) ||
                            ($booking->end_time > $start_time && $booking->end_time <= $end_time);
                    });

                if ($hasBookingsInPeriod) {
                    continue;
                }

                $filteredSlots = array_filter($allHours, function ($slot) use ($bookedSlots, $dateStr, $start_time, $end_time) {
                    foreach ($bookedSlots[$dateStr] ?? [] as $booked) {
                        if (
                            ($slot['start_time'] >= $booked->start_time && $slot['start_time'] < $booked->end_time) ||
                            ($slot['end_time'] > $booked->start_time && $slot['end_time'] <= $booked->end_time)
                        ) {
                            return false;
                        }
                    }
                    return (!$start_time || !$end_time) || ($slot['start_time'] >= $start_time && $slot['end_time'] <= $end_time);
                });
                foreach ($filteredSlots as $slot) {
                    $availableSlots[] = [
                        'date' => $dateStr,
                        'start_time' => $slot['start_time'],
                        'end_time' => $slot['end_time'],
                        'club_id' => $field->id,
                        'club' => $field->name,
                        'category_id' => optional($field->schServiceCategories->first())->id,
                        'category_name' => optional($field->schServiceCategories->first())->name,
                        'service_id' => optional(optional($field->schServiceCategories->first())->services->first())->id,
                        'service_title' => optional(optional($field->schServiceCategories->first())->services->first())->title,
                        'address' => $field->address,
                        'latitude' => $field->lat,
                        'longitude' => $field->long,
                    ];
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
            })
            ->orderBy('date', 'desc')
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

        $employeeId = $validated['employee_id'];
        $serviceId = $validated['service_id'];
        $serviceBranchId = $validated['branch_id'];
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
                $customer = CmnCustomer::where('user_id', auth()->id())->select('id', 'phone_no','user_id')->first();
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
                throw new ErrorException(
                    __('messages.The selected service is not available at the chosen time. Please select a different time.') .
                    " [التاريخ: {$serviceDate}, من: {$serviceStartTime} إلى: {$serviceEndTime}]"
                );
            }

            $bookingRepo = new BookingRepository();
            if ($bookingRepo->serviceIsAvaiable($serviceId, $employeeId, $serviceDate, $serviceStartTime, $serviceEndTime, true) > 0) {
                throw new ErrorException(
                    __('messages.The selected service is not available at the chosen time. Please select a different time.') .
                    " [التاريخ: {$serviceDate}, من: {$serviceStartTime} إلى: {$serviceEndTime}]"
                );
            }



            $serviceStatus = $paymentType == PaymentType::UserBalance ? ServiceStatus::Done : ServiceStatus::Processing;

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
                'paid_amount' => 0,
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
                'created_by' => auth()->id()
            ]);

            $serviceBookingInfo->serviceBookings()->attach($serviceList);

            DB::commit();

            if ($paymentType == PaymentType::LocalPayment) {
                //? todo send notification to customer 
                $this->sendBookingDetails($phoneNo, $fullName, $serviceBookingInfo , $paymentType);
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

                //? todo send notification to customer 
                $user = $customer->user;
                $branch = CmnBranch::find($serviceBranchId);
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

            $dataCollection = collect($data);
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
            return response()->json(['status' => 'true' , 'message' => __('messages.Booking status changed successfully') , 'data' => $formattedBooking], 200);

        } catch (ErrorException | Exception $ex) {
            return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 400);
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




}    