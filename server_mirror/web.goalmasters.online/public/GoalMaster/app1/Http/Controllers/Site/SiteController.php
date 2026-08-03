<?php

namespace App\Http\Controllers\Site;

use illuminate\Support\Facades\App;
use Exception;
use Carbon\Carbon;
use ErrorException;
use App\Models\User;
use App\Models\Zone;
use App\Enums\UserType;
use App\Enums\PaymentFor;
use App\Enums\BalanceType;
use App\Enums\MessageType;
use App\Enums\PaymentType;
use App\Enums\ProductType;
use App\Enums\ServiceStatus;
use App\Services\OTPService;
use Illuminate\Http\Request;
use App\Events\BookingCreated;
use App\Models\Order\CmnOrder;
use App\Enums\ServiceVisibility;
use App\Services\WhatsAppService;
use App\Models\Settings\CmnBranch;
use Illuminate\Support\Facades\DB;
use App\Enums\ServicePaymentStatus;
use App\Models\Settings\CmnProduct;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use App\Models\Customer\CmnCustomer;
use Illuminate\Support\Facades\Auth;
use App\Models\Order\CmnOrderDetails;
use Illuminate\Support\Facades\Cache;
use App\Models\Payment\CmnPaymentType;
use App\Models\Website\SiteAppearance;
use App\Models\Settings\CmnBusinessHour;
use App\Notifications\OrderNotification;
use App\Enums\ServiceCancelPaymentStatus;
use App\Models\Booking\SchServiceBooking;
use App\Http\Repository\UtilityRepository;
use App\Models\Employee\SchEmployeeOffday;
use App\Models\UserManagement\SecUserRole;
use App\Http\Repository\DateTimeRepository;
use App\Models\Employee\SchEmployeeService;
use App\Models\Services\SchServiceCategory;
use App\Models\Settings\CmnBusinessHoliday;
use App\Http\Controllers\WhatsAppController;
use App\Models\Employee\SchEmployeeSchedule;
use App\Models\UserManagement\SecUserBranch;
use Illuminate\Support\Facades\Notification;
use App\Models\Booking\SchServiceBookingInfo;
use App\Notifications\ClientQueryNotification;
use App\Notifications\ServiceOrderNotification;
use App\Http\Repository\Coupon\CouponRepository;
use App\Http\Controllers\Payment\PaypalController;
use App\Http\Controllers\Payment\StripeController;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Repository\Payment\PaymentRepository;
use App\Http\Repository\Language\LanguageRepository;
use App\Http\Repository\Settings\SettingsRepository;
use App\Http\Repository\Dashboard\DashboardRepository;
use App\Http\Repository\SmsNotification\SmsNotificationRepository;

class SiteController extends Controller
{

    protected $whatsAppService;

    public function __construct(WhatsAppService $whatsAppService)
    {
        $this->whatsAppService = $whatsAppService;
    }

    private function sendBookingDetails($phoneNo, $fullName, $serviceBookingInfo ,$payment_type)
    {
        $bookingRepo = new BookingRepository();
        $bookings = $bookingRepo->getServiceInvoice($serviceBookingInfo->id)->order_details;
        foreach ($bookings as $book) {
            $book['payment_type'] = $payment_type;
            $book['web'] = 1;
            $this->whatsAppService->sendMessage($phoneNo, $fullName, $book);
        }
    }      


    public function index()
    {
        if (UtilityRepository::isSiteInstalled() == false) {
            return view("vendor.installer.welcome");
        } else {
            $websiteCont = new WebsiteController();
            $dashboard = new DashboardRepository();
            return view('site.index', [
                'topService' => $websiteCont->getTopServices(),
                'clientTestimonial' => $websiteCont->getClientTestimonial(),
                'newJoiningEmployee' => $websiteCont->getNewJoiningEmployee(),
                'serviceSummary' => $dashboard->getWebsiteServiceSummary()
            ]);
        }
    }


    public function paymentComplete()
    {
        $data = [
            'message' => 'اكتمل ايداع الدفعه بنجاح',
            'redirect_link' => 'client.dashboard',
            'redirect_text' => 'Go to dashboard'
        ];
        return view('site.success', ['data' => $data]);
    }
    public function unsuccessfulPayment()
    {
        $data = [
            'message' => 'Payment Failed!',
            'redirect_link' => 'client.dashboard',
            'redirect_text' => 'Go to dashboard'
        ];
        return view('site.error', ['data' => $data]);
    }


    public function getServiceCategory()
    {
        try {
            $data = SchServiceCategory::select(
                'id',
                'name',
                'cmn_branch_id'
            )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getService(Request $request)
    {
        try {
            $bookingRepo = new BookingRepository();
            $data = $bookingRepo->getService($request->sch_service_category_id, ServiceVisibility::PublicService);
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getBranch()
    {

        $isAllBranch = true;
        if (Auth()->id()) {

            $user = User::where('id', Auth()->id())->first();
            $userType = $user->user_type;
            if (!($user->is_sys_adm || $userType  == 2)) {
                $isAllBranch = false;
            }
        }

        if ($isAllBranch) {

            try {
                $data = CmnBranch::select(
                    'id',
                    'name',
                    'zone_id'
                )->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (Exception $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }
        } else {
            $userBranch = SecUserBranch::where('user_id', Auth()->id())->select('cmn_branch_id')->get();
            try {
                $data = CmnBranch::select(
                    'id',
                    'name',
					'zone_id'
                    // ) ->whereIn('id', $br->getUserBranch()->pluck('cmn_branch_id'))
                )->whereIn('id', $userBranch->pluck('cmn_branch_id'))
                    ->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (Exception $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }
        }


        // try {
        //     $data = CmnBranch::select(
        //         'id',
        //         'name'
        //     )->get();
        //     return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        // } catch (Exception $qx) {
        //     return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        // }
    }

    public function getZone()
    {

		try {
		    $isAllBranch = true;
			$userBranchIds = [];
			if (Auth()->id()) {
				
				$user = User::where('id', Auth()->id())->first();
				$userType = $user->user_type;
				if (!($user->is_sys_adm || $userType  == 2)) {
					$isAllBranch = false;
					$userBranchIds = SecUserBranch::where('user_id', Auth()->id())->select('cmn_branch_id')->get()->pluck('cmn_branch_id')->toArray();
				}
			}
			$data = Zone::select(
				'id',
				'name'
			)->when(!$isAllBranch, function($q) use ($userBranchIds){
				$q->whereHas('branches', function($query) use ($userBranchIds){
					$query->whereIn('id', $userBranchIds);
				});
			})->get();
			return $this->apiResponse(['status' => '1', 'data' => $data], 200);
		} catch (Exception $qx) {
			return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
		}
    }


    public function getEmployeeService(Request $request)
    {
        try {

            $bookingRepo = new BookingRepository();
            $rtr = $bookingRepo->getEmployeeByService($request->sch_service_id, $request->cmn_branch_id, [1]);
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }


    public function getServiceTimeSlot(Request $request)
    {
        try {

            $bookingRepo = new BookingRepository();
            $day = (new Carbon($request->date))->format('w');
            $date = $request->date;

            //check employee holiday
            $employeeOffDay = SchEmployeeOffday::where('sch_employee_id', $request->sch_employee_id)
                ->where('start_date', '<=',  $date)->where('end_date', '>=',  $date)->exists();
            if ($employeeOffDay) {
                return $this->apiResponse(['status' => '5', 'data' => "Selected date is Staff Holiday/Leave"], 400);
            }

            //check employee holiday
            $employeeSchedule = $schedule = SchEmployeeSchedule::where('sch_employee_id', $request->sch_employee_id)
                ->where('day', $day)->where('is_off_day', 1)->exists();
            if ($employeeSchedule) {
                return $this->apiResponse(['status' => '5', 'data' => translate("Today is weekly holiday")], 400);
            }

            //check business holiday
            $businessHoliday = CmnBusinessHoliday::where('cmn_branch_id', $request->cmn_branch_id)
                ->where('start_date', '<=', $date)->where('end_date', '>=', $date)->exists();

            if ($businessHoliday) {
                return $this->apiResponse(['status' => '5', 'data' => "Selected date is business holiday try another one."], 400);
            }

            //check weekly holiday
            $businessHours = CmnBusinessHour::where('is_off_day', 1)->where('cmn_branch_id', $request->cmn_branch_id)->where('day', $day)->exists();
            if ($businessHours) {
                return $this->apiResponse(['status' => '5', 'data' => "Selected date is weekly holiday try another one."], 400);
            }

            //get employee schedule
            $schedule = SchEmployeeSchedule::where('sch_employee_id', $request->sch_employee_id)
                ->where('day', $day)->select(
                    'start_time',
                    'end_time',
                    'break_start_time',
                    'break_end_time',
                )->first();

            //get employee service
            $service = SchEmployeeService::join('sch_services', 'sch_employee_services.sch_service_id', '=', 'sch_services.id')
                ->where('sch_services.id', $request->sch_service_id)
                ->where('sch_employee_services.sch_employee_id', $request->sch_employee_id);

            if (!$request->has('visibility')) {
                $service = $service->where('sch_services.visibility', ServiceVisibility::PublicService);
            }

            $service = $service->select(
                'sch_services.duration_in_days',
                'sch_services.duration_in_time',
                'sch_services.time_slot_in_time',
                'sch_services.padding_time_before',
                'sch_services.padding_time_after',
                'sch_employee_services.fees'
            )->first();


            $avaiableService = array();
            if ($schedule != null && $service != null) {
                // $startTimeInMinute = DateTimeRepository::TotalMinuteFromTime($schedule->start_time);
                // $breakStartTimeInMinute = DateTimeRepository::TotalMinuteFromTime($schedule->break_start_time);
                // $breakEndTimeInMinute = DateTimeRepository::TotalMinuteFromTime($schedule->break_end_time);
                // $endTimeInMinute = DateTimeRepository::TotalMinuteFromTime($schedule->end_time);
                // $timeSlotInMinute = DateTimeRepository::TotalMinuteFromTime($service->time_slot_in_time);
                // $paddingTimeBeforeInMinute = DateTimeRepository::TotalMinuteFromTime($service->padding_time_before);
                // $paddingTimeAfterInMinute = DateTimeRepository::TotalMinuteFromTime($service->padding_time_after);

                // //get time slot before break time
                // $serviceStartTimeBefore = $startTimeInMinute + $paddingTimeBeforeInMinute;
                // $serviceEndTimeAfter = $breakStartTimeInMinute + $paddingTimeAfterInMinute;
                // for ($sTime = $serviceStartTimeBefore; $sTime <= $serviceEndTimeAfter; $sTime = ($sTime + $timeSlotInMinute + $paddingTimeAfterInMinute + $paddingTimeBeforeInMinute)) {
                //     $serviceEndTimeInMinute = $sTime + $timeSlotInMinute;
                //     if ($breakStartTimeInMinute >= $serviceEndTimeInMinute) {
                //         $avaiableService[] = [
                //             'start_time' => DateTimeRepository::MinuteToTime($sTime),
                //             'end_time' => DateTimeRepository::MinuteToTime($serviceEndTimeInMinute),
                //             'is_avaiable' => 1
                //         ];
                //     }
                // }

                // //get time slot after break end time
                // $serviceStartTimeBefore = $breakEndTimeInMinute + $paddingTimeBeforeInMinute;
                // $serviceEndTimeAfter = $endTimeInMinute + $paddingTimeAfterInMinute;
                // for ($sTime = $serviceStartTimeBefore; $sTime <= $serviceEndTimeAfter; $sTime = ($sTime + $timeSlotInMinute + $paddingTimeAfterInMinute + $paddingTimeBeforeInMinute)) {
                //     $serviceEndTimeInMinute = $sTime + $timeSlotInMinute;
                //     if ($endTimeInMinute >= $serviceEndTimeInMinute) {
                //         $avaiableService[] = [
                //             'start_time' => DateTimeRepository::MinuteToTime($sTime),
                //             'end_time' => DateTimeRepository::MinuteToTime($serviceEndTimeInMinute),
                //             'is_avaiable' => 1
                //         ];
                //     }
                // }

                /////////////////////////////////

                $startTimeInMinute = DateTimeRepository::TotalMinuteFromTime($schedule->start_time);
                $endTimeInMinute = DateTimeRepository::TotalMinuteFromTime($schedule->end_time);
                $timeSlotInMinute = DateTimeRepository::TotalMinuteFromTime($service->time_slot_in_time);

                

                // dd($startTimeInMinute != 0 && $endTimeInMinute != 0);
                if ($endTimeInMinute != 0) {

                    for ($sTime = $startTimeInMinute; $sTime <= $endTimeInMinute; $sTime = ($sTime + $timeSlotInMinute)) {
                        $serviceEndTimeInMinute = $sTime + $timeSlotInMinute;
                            $avaiableService[] = [
                                'start_time' => DateTimeRepository::MinuteToTime($sTime),
                                'end_time' => DateTimeRepository::MinuteToTime($serviceEndTimeInMinute),
                                'is_avaiable' => 1
                            ];
                    }
                }

                


                //check service is avaiable or not
                foreach ($avaiableService as $key => $val) {
                    if ($bookingRepo->serviceIsAvaiable($request->sch_service_id, $request->sch_employee_id, $date, $val['start_time'], $val['end_time']) > 0)
                        $avaiableService[$key]['is_avaiable'] = 0;
                }
                return $this->apiResponse(['status' => '1', 'data' => $avaiableService], 200);
            } else {
                return $this->apiResponse(['status' => '2', 'data' => 'Service is not avaiable today'], 400);
            }
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getPaymentType()
    {
        try {
            $payRp = new PaymentRepository();
            return $this->apiResponse(['status' => '1', 'data' => $payRp->getPaymentMethod()], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function cancelBooking(Request $request)
    {
        return  $this->cancelService($request->serviceBookingId);
    }


    public function cancelService($serviceBookingId)
    {
        try {
            $bookedService = SchServiceBooking::where('sch_service_booking_info_id', $serviceBookingId)->get();
            $bookedService->status = ServiceStatus::Cancel;
            $bookedService->update();
            return $this->apiResponse(['status' => '1', 'data' => ""], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function cancelServiceOrder($serviceBookingInfoId)
    {

        $bookedService = SchServiceBooking::where('sch_service_booking_info_id', $serviceBookingInfoId)->get();
        foreach ($bookedService as $kay) {
            $kay->status = ServiceStatus::Cancel;
        }
        return  $bookedService->update();
    }


    public function saveBooking(Request $request)
    {
        $serviceId = $request->bookingData['items'][0]['sch_employee_id'];
        $serviceBranchId = $request->bookingData['items'][0]['cmn_branch_id'];
        $managerID =DB::table('sec_user_branches')->where('cmn_branch_id', $serviceBranchId)->first()->user_id;
        DB::beginTransaction();
        try {
            $request = (object)$request->bookingData;
            $bookingRepo = new BookingRepository();
            $customerId = 0;
            $customer = "";

            //if login by user
            if (auth()->check()) {
                $customer = CmnCustomer::where('user_id', auth()->id())->select('id', 'phone_no')->first();
                if ($request->payment_type == PaymentType::UserBalance) {
                    $userBalance = auth()->user()->balance();
                    if ($userBalance == null)
                        throw new ErrorException(translate('You do not have enough balance in your account'));
                }
            } else {
                if ($request->payment_type == PaymentType::UserBalance)
                    throw new ErrorException(translate("You can't make payment by user balance without login try another one"));
                $customer = CmnCustomer::where('phone_no', $request->phone_no)->first();
            }
            if ($customer != null) {
                $customerId = $customer->id;
            } else {
                $saveCustomer = [
                    'full_name' => $request->full_name,
                    'phone_no' => $request->phone_no,
                    // 'email' => $request->email,
                    'state' => $request->state,
                    'postal_code' => $request->postal_code,
                    'city' => $request->city,
                    'street_address' => $request->street_address
                ];
                $cstRtrn = CmnCustomer::create($saveCustomer);
                $customerId = $cstRtrn->id;
            }
            $exists = DB::table('manager_customer')
                ->where('manager_id', $managerID)
                ->where('customer_id', $customer->id)
                ->exists();

            if (!$exists) {
                DB::table('manager_customer')->insert([
                    'full_name' => $request->full_name,
                    'manager_id' => $managerID,
                    'customer_id' => $customer->id,
                ]);
            }
            //customer creation/get failed
            if ($customerId == 0)
                throw new ErrorException(translate("Failed to save or get customer"));
            //insert service booking
            $serviceList = array();
            $serviceTotalAmount = 0;
            foreach ($request->items as $key => $item) {
                $item = (object)$item;
                //get employee wise service charge
                $serviceCharge = SchEmployeeService::where('sch_employee_id', $item->sch_employee_id)
                    ->where('sch_service_id', $item->sch_service_id)->select('fees')->first();
                if ($serviceCharge == null)
                    throw new ErrorException(translate("This service is not avaiable please try another one.") . ' "' . $item->service_name . '"');

                $serviceTime = explode('-', $item->service_time);
                $serviceStartTime = $serviceTime[0];
                $serviceEndTime = $serviceTime[1];

                //check service is booked or not
                if ($bookingRepo->serviceIsAvaiable($item->sch_service_id, $item->sch_employee_id, $item->service_date, $serviceStartTime, $serviceEndTime,true) > 0)
                    throw new ErrorException(translate("The selected service is bocked try another one") . ' "' . $item->service_name . '"');

                //check servicce limitation
                $serviceLimitation = $bookingRepo->IsServiceLimitation($item->service_date, $serviceStartTime, $customerId, $item->sch_service_id, 1, 1);
                if ($serviceLimitation['allow'] < 1)
                    throw new ErrorException(translate($serviceLimitation['message']));

                $serviceStatus = ServiceStatus::Pending;
                if ($request->payment_type == PaymentType::LocalPayment) {
                    $serviceStatus = ServiceStatus::Processing;
                }
                else if ($request->payment_type == PaymentType::UserBalance) {
                    $serviceStatus = ServiceStatus::Done;
                }
                
                //total service charge
                $serviceTotalAmount = $serviceTotalAmount + $serviceCharge->fees;

                $serviceList[] = [
                    'id' => null,
                    'cmn_branch_id' => $item->cmn_branch_id,
                    'cmn_customer_id' => $customerId,
                    'sch_employee_id' => $item->sch_employee_id,
                    'date' => $item->service_date,
                    'start_time' => $serviceStartTime,
                    'end_time' => $serviceEndTime,
                    'sch_service_id' => $item->sch_service_id,
                    'status' => $serviceStatus,
                    'service_amount' => $serviceCharge->fees,
                    'paid_amount' => 0,
                    'payment_status' => ServicePaymentStatus::Unpaid,
                    'cmn_payment_type_id' => $request->payment_type,
                    'canceled_paid_amount' => 0,
                    'cancel_paid_status' => ServiceCancelPaymentStatus::Unpaid,
                    'remarks' => $request->service_remarks,
                    'created_by' => $customerId
                ];
            }
            Log::info('service list', ['serviceList' => $serviceList]);

            $payableAmount = $serviceTotalAmount;
            if ($request->payment_type == PaymentType::UserBalance) {
                $userBalance = auth()->user()->balance();
                if ($userBalance < $payableAmount)
                    throw new ErrorException(translate('You do not have enough balance in your account'));
            }
            $couponDiscount = 0;
            //get voucher discount
            if (UtilityRepository::emptyOrNullToZero($request->coupon_code) != 0) {
                $couponRepo = new CouponRepository();
                $couponDiscount = $couponRepo->validateAndGetCouponValue(auth()->id(), $request->coupon_code, $serviceTotalAmount);
            }
            if ($couponDiscount > 0) {
                $payableAmount = $payableAmount - $couponDiscount;
            } else {
                $couponDiscount = 0;
            }

            $serviceBookingInfo = SchServiceBookingInfo::create([
                'booking_date' => Carbon::now(),
                'cmn_customer_id' => $customerId,
                'total_amount' => $serviceTotalAmount,
                'payable_amount' => $payableAmount,
                'paid_amount' => $payableAmount,
                'due_amount' => $payableAmount,
                'is_due_paid' => 0,
                'coupon_code' => $request->coupon_code,
                'coupon_discount' => $couponDiscount,
                'remarks' => $request->service_remarks,
                'created_by' => auth()->id()
            ]);
            $serviceBookingInfo->serviceBookings()->attach($serviceList);
            DB::commit();
            Log::info('service Booking info', ['servicebooking info' => $serviceBookingInfo]);

            //send notification to user

            // if (UtilityRepository::isEmailConfigured()) {
            //     $user = '';
            //     if (auth()->check()) {
            //         $user = auth()->user();
            //     } else {
            //         $user = User::first();
            //         // $user->email = $request->email;
            //         $user->phone_no = $request->phone_no;
            //         $user->full_name = $request->full_name;
            //     }
            //     $bookingRepo = new BookingRepository();
            //     Notification::send($user, new ServiceOrderNotification($bookingRepo->getServiceInvoice($serviceBookingInfo->id)));
            // }

           
            // $this->whatsAppService->sendMessage($request->phone_no, $request->full_name, $bookingRepo->getServiceInvoice($serviceBookingInfo->id));

            $userstobenotified = [];
            $users = User::where('user_type', 1)->get();
            foreach ($users as $user) {
                if ($user->is_sys_adm) {
                    $userstobenotified[] = $user;
                    continue;
                }
                if ($user->sch_employee_id == $serviceId) {
                    $userstobenotified[] = $user;
                } elseif ($user->sch_employee_id == null) {
                    $userBranches = SecUserBranch::where('user_id', $user->id)
                        ->where('cmn_branch_id', $serviceBranchId)
                        ->exists();
                    if ($userBranches) {
                        $userstobenotified[] = $user;
                    }
                }
            }
            // $SystemUsers = User::where('user_type', '1')->get();
            $usr="";
            if(auth()->check()){
                $usr = Auth::user();
            }
            else
            {
                $usr = $customer;
            }
            $bookingss=$bookingRepo->getServiceInvoice($serviceBookingInfo->id)->order_details;
            foreach ($bookingss as $book) {
                Notification::send($userstobenotified, new ServiceOrderNotification($book, $usr));
                event(new BookingCreated($book, $userstobenotified, $usr));
            }
            Log::info('userstobenotified', ['userstobenotified ' => $userstobenotified]);

            // Notification::send($userstobenotified, new ServiceOrderNotification($bookingRepo->getServiceInvoice($serviceBookingInfo->id), $usr));
            // event(new BookingCreated($bookingRepo->getServiceInvoice($serviceBookingInfo->id), $userstobenotified, $usr));

            // //SMS notification
            // SmsNotificationRepository::sendNotification(
            //     $request->phone_no,
            //     MessageType::ServiceStatus,
            //     [
            //         ['key' => '{order_number}', 'value' =>   $serviceBookingInfo->id]
            //     ]
            // );


            if ($request->payment_type == PaymentType::LocalPayment) {
                $this->sendBookingDetails($request->phone_no, $request->full_name, $serviceBookingInfo,$request->payment_type);
                return $this->apiResponse(['status' => 1, 'paymentType' => 'localPayment', 'data' => "successfully save"], 200);
            } else {
                //this is for fontend
                $paymentTypeForRtrn = 'paypal';
                if ($request->payment_type == PaymentType::Stripe)
                    $paymentTypeForRtrn = 'stripe';
                else if ($request->payment_type == PaymentType::Paypal)
                    $paymentTypeForRtrn = 'paypal';
                else if ($request->payment_type == PaymentType::UserBalance)
                    $paymentTypeForRtrn = 'userBalance';

                $paymentRepo = new PaymentRepository();
                $return = $paymentRepo->makePayment($request->payment_type, $payableAmount, PaymentFor::ServiceCharge, $serviceBookingInfo->id);
                $serviceBooking = SchServiceBooking::where('sch_service_booking_info_id', $serviceBookingInfo->id)->first();
                $serviceBooking->update([
                    'paid_amount' => $serviceBooking->service_amount, 
                    'payment_status' => ServicePaymentStatus::Paid,
                    'status' => ServiceStatus::Done, 
                ]);
                $this->sendBookingDetails($request->phone_no, $request->full_name, $serviceBookingInfo,$request->payment_type);
                return $this->apiResponse(['status' => 1, 'paymentType' => $paymentTypeForRtrn, 'data' => ['serviceBookingId' => $serviceBookingInfo->id, 'returnUrl' => $return]], 200);
            }
        } catch (ErrorException $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getLoginCustomerInfo()
    {
        try {
            if (auth()->check()) {
                $settingRepo = new SettingsRepository();
                return $this->apiResponse(['status' => '1', 'data' => $settingRepo->getCustomer(auth()->id())], 200);
            }
            return $this->apiResponse(['status' => '0', 'data' => 'no data found'], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function serviceDuePayment(Request $request)
    {
        try {
            $bookingInfo = SchServiceBooking::where('id', $request->bookingId)->select('service_amount', 'paid_amount', 'status', 'sch_service_booking_info_id')->first();
            if ($bookingInfo != null) {
                $dueAmount = $bookingInfo->service_amount - $bookingInfo->paid_amount;
                if ($bookingInfo->status != ServiceStatus::Cancel && $bookingInfo->status != ServiceStatus::Done && $dueAmount > 0) {
                    $paymentTypeForRtrn = 'paypal';
                    if ($request->paymentType == PaymentType::Stripe)
                        $paymentTypeForRtrn = 'stripe';
                    else if ($request->paymentType == PaymentType::Paypal)
                        $paymentTypeForRtrn = 'paypal';
                    else if ($request->paymentType == PaymentType::UserBalance)
                        $paymentTypeForRtrn = 'userBalance';

                    $paymentRepo = new PaymentRepository();
                    $return = $paymentRepo->makePayment($request->paymentType, $dueAmount, PaymentFor::ServiceDuePayment, $request->bookingId);
                    return $this->apiResponse(['status' => 1, 'paymentType' => $paymentTypeForRtrn, 'data' => ['serviceBookingId' => $request->bookingId, 'returnUrl' => $return]], 200);
                }
                throw new ErrorException("This service is not available to payment.");
            }
            throw new ErrorException("Invalid payment request or changed url.");
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }


    public function sendClientNotification(Request $request)
    {
        try {
            // //send notification to user
            // if (UtilityRepository::isEmailConfigured()) {
            //     $apperance = SiteAppearance::select('contact_email', 'app_name', 'contact_phone')->first();

            //     $user = User::first();
            //     $user->email = $apperance->contact_email;
            //     $user->phone_no = $apperance->contact_phone;
            //     $user->full_name = $apperance->app_name;

            //     $serviceMessage = [
            //         'name' => $request->name,
            //         'email' => $request->email,
            //         'subject' => $request->subject,
            //         'message' => $request->message
            //     ];
            //     Notification::send($user, new ClientQueryNotification($serviceMessage));
            //     return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            // }
            // return $this->apiResponse(['status' => '-501', 'data' => 'Failed to send email'], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function changeLanguage(Request $request)
    {
        try {
            $langRepo = new LanguageRepository();
            $langRepo->setLangaugeSession($request->lang_id);

            return redirect()->back();
        } catch (Exception $ex) {
            return $ex;
        }
    }

    public function cart(Request $request)
    {
        $carts = collect(session()->get('user_cart') ?? []);
        return view('site.cart', compact('carts'));
    }

    public function addToCart(Request $request, CmnProduct $cmnProduct)
    {
        if (!$cmnProduct->status || $cmnProduct->quantity < $request->qty) {
            return ['status' => 0, 'msg' => 'Out of stock'];
        }
        if (session()->get('user_cart')) {
            $carts = collect(session()->get('user_cart'));
        } else {
            $carts = collect([]);
        }

        if ($carts->where('cmn_product_id', $cmnProduct->id)->first()) {
            foreach ($carts as $key => $cart) {
                if ($cart['cmn_product_id'] == $cmnProduct->id) {
                    $cart['quantity'] += $request->qty;
                    if ($cart['quantity'] > $cmnProduct->quantity) {
                        return ['status' => 0, 'msg' => 'Out of stock'];
                    }
                    $cart['total_price'] = $cart['quantity'] * ($cart['price'] - (($cart['price'] * $cart['discount']) / 100));
                    $carts[$key] = $cart;
                }
            }
        } else {
            $carts[] = [
                'cmn_product_id' => $cmnProduct->id,
                'name' => $cmnProduct->name,
                'cmn_type_id' => $cmnProduct->cmn_type_id,
                'cmn_category_id' => $cmnProduct->cmn_category_id,
                'price' => $cmnProduct->price - (($cmnProduct->price * $cmnProduct->discount) / 100),
                'total_price' => ($cmnProduct->price - (($cmnProduct->price * $cmnProduct->discount) / 100)) * $request->qty,
                'thumbnail' => $cmnProduct->thumbnail,
                'unit' => $cmnProduct->unit,
                'discount' => (float)$cmnProduct->discount,
                'discount_type' => $cmnProduct->discount_type,
                'quantity' => (int)$request->qty
            ];
        }

        session()->put('user_cart', $carts);
        return ['status' => 1, 'cart' => $carts];
    }

    public function removeFromCart(Request $request)
    {
        $carts = collect(session()->get('user_cart'));
        if (isset($carts[$request->index])) {
            unset($carts[$request->index]);
        }

        session()->put('user_cart', $carts);
        return ['status' => 1, 'cart' => $carts];
    }

    public function shipping(Request $request)
    {
        $user = auth()->user();
        return view('site.shipping_info', compact('user'));
    }

    public function shippingCart(Request $request)
    {
        $shipping = [
            'full_name' => $request->input('full_name'),
            'email' => $request->input('email'),
            'phone' => $request->input('phone'),
            'address' => $request->input('address')
        ];
        session()->put('cart_shipping', $shipping);
        return redirect()->route('site.order.payment');
    }


    public function orderPayment()
    {
        return view('site.client.client-order-payment');
    }

    public function processToPayOrderAmount(Request $request)
    {
        try {
            $carts = collect(session()->get('user_cart'));
            $payableAmount = round($carts->sum('total_price'), 2);

            //this is for fontend
            $paymentTypeForRtrn = 'paypal';
            if ($request->payment_type == PaymentType::Stripe) {
                $paymentTypeForRtrn = 'stripe';
            } else if ($request->payment_type == PaymentType::Paypal) {
                $paymentTypeForRtrn = 'paypal';
            } else if ($request->payment_type == PaymentType::UserBalance) {
                throw new ErrorException(translate("You can't make payment by user balance"));
            } else if ($request->payment_type == PaymentType::LocalPayment) {
                throw new ErrorException(translate("You can't make payment by Cash"));
            }
            $paymentRepo = new PaymentRepository();
            $return = $paymentRepo->makePayment($request->payment_type, $payableAmount, PaymentFor::OrderPayment, 0);
            return $this->apiResponse(['status' => 1, 'paymentType' => $paymentTypeForRtrn, 'data' => ['serviceBookingId' => 0, 'returnUrl' => $return]], 200);
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function orderStore(Request $request)
    {
        DB::beginTransaction();
        try {
            $carts = collect(session()->get('user_cart'));
            if ($carts->count() > 0) {
                $order = CmnOrder::create([
                    'user_id' => auth()->id(),
                    'amount' => $carts->sum('total_price'),
                    'shipping_details' => session()->get('cart_shipping'),
                    'payment_status' => 'paid'
                ]);

                $order->code = ($order->id < 99999) ? str_pad($order->id, 6, '0', STR_PAD_LEFT) : $order->id;
                $order->update();

                foreach ($carts as $key => $item) {
                    $orderDetails = $order->details()->create([
                        'cmn_product_id' => $item['cmn_product_id'],
                        'product_price' => $item['price'],
                        'product_quantity' => $item['quantity'],
                        'total_price' => $item['total_price'],
                        'discount_amount' => 0,
                        'shipping_amount' => 0,
                        'paid_amount' => 0,
                    ]);

                    if ($orderDetails->product->cmn_type_id == ProductType::Voucher) {
                        $orderDetails->balance()->create([
                            'amount' => $orderDetails->product->price * $item['quantity'],
                            'user_id' => auth()->id(),
                            'balance_type' => BalanceType::CR,
                            'status' => 0
                        ]);
                    }

                    $product = CmnProduct::find($item['cmn_product_id']);
                    $product->quantity -= $item['quantity'];
                    $product->update();
                }

                session()->forget('cart_shipping');
                session()->forget('user_cart');
                DB::commit();

                auth()->user()->notify((new OrderNotification($order)));

                return redirect()->route('site.order.thankyou', ['cmnOrder' => $order->code]);
            }
        } catch (Exception $e) {
            DB::rollBack();
            if (env('APP_DEBUG'))
                dd($e);
        }
    }

    public function orderThankyou(Request $request, CmnOrder $cmnOrder)
    {
        return view('site.cart_thankyou', ['order' => $cmnOrder]);
    }

    public function getCouponAmount(Request $request)
    {
        try {
            $couponRepo = new CouponRepository();
            $data = $couponRepo->validateAndGetCouponValue(auth()->id(), $request->couponCode, $request->orderAmount);
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }
}
