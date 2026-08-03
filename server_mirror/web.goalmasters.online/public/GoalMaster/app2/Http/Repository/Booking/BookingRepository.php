<?php

namespace App\Http\Repository\Booking;

use Exception;
use Carbon\Carbon;
use ErrorException;
use App\Models\User;
use App\Enums\MessageType;
use App\Enums\ServiceStatus;
use App\Events\BookingStatus;
use App\Events\BookingCreated;
use App\Services\WhatsAppService;
use App\Enums\AppointmentLimitType;
use App\Enums\ServicePaymentStatus;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use App\Models\Customer\CmnCustomer;
use App\Models\Employee\SchEmployee;
use App\Models\Services\SchServices;
use Illuminate\Support\Facades\Auth;
use App\Models\Payment\CmnCurrencySetup;
use App\Models\Settings\CmnBusinessHour;
use App\Models\Booking\SchServiceBooking;
use App\Http\Repository\UtilityRepository;
use App\Http\Repository\DateTimeRepository;
use App\Models\Employee\SchEmployeeService;
use App\Models\UserManagement\SecUserBranch;
use Illuminate\Support\Facades\Notification;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Booking\BookingPaymentTolerance;
use App\Notifications\ServiceBookingNotification;
use PhpOffice\PhpSpreadsheet\Calculation\Web\Service;
use App\Notifications\ServiceBookingFeedbackNotification;
use App\Http\Repository\SmsNotification\SmsNotificationRepository;
use Illuminate\Support\Facades\DB;

class BookingRepository
{

    /**
     * cancel booking with check is available to cancel
     * emailNotify=1 for send service notification by email otherwise not send email
     */
    public function availableToCancelBooking($bookingId, $emailNotify, $user)
    {
        if ($this->IsServiceAvailableToCancel($bookingId) > 0) {
            $updateData = SchServiceBooking::where('id', $bookingId)->first();
            $updateData->status = ServiceStatus::Cancel;
            $updateData->updated_by = Auth::id();
            $updateStatus = $updateData->update();
            $serviceId = $updateData->sch_service_id;
            $cmn_branch_id = $updateData->cmn_branch_id;
            $serviceDate = new Carbon($updateData->service_date);
            $serviceMessage = [
                'user_name' => $user->name,
                'message_subject' => 'Booking ' . UtilityRepository::serviceStatus($updateData->status) . ' Notification',
                'message_body' => 'Your service request is ' . UtilityRepository::serviceStatus($updateData->status) . '.',
                'booking_info' => ' Booking No#' .  $updateData->id . ', Service Date# ' . $serviceDate->format('D, M d, Y') . ' at ' . $updateData->start_time . ' to ' .  $updateData->end_time,
                'message_footer' => 'Thanks you for choosing our service.',
                'action_url' => url('/client-dashboard'),
                'message' => " تم تغيير حالة الحجز الخاص ب" . $user->name . ' إلي حالة ' . UtilityRepository::serviceStatus($updateData->status) . ' بواسطة ' . Auth::user()->name,
                'id' => $updateData->id
            ];
            // //send notification to user
            // if ($emailNotify == 1 && $user != null && UtilityRepository::isEmailConfigured()) {
            //     //Email notification
            //     Notification::send($user, new ServiceBookingNotification($serviceMessage));
            // }
            $currentUserId = Auth::id();
            $userstobenotified = [];
            $users = User::where('user_type', 1)->get();
            foreach ($users as $user) {
                if ($user->id == $currentUserId) {
                    continue;
                }
                if ($user->is_sys_adm) {
                    $userstobenotified[] = $user;
                    continue;
                }
                if ($user->sch_employee_id == $serviceId) {
                    $userstobenotified[] = $user;
                } elseif ($user->sch_employee_id == null) {
                    $userBranches = SecUserBranch::where('user_id', $user->id)
                        ->where('cmn_branch_id', $cmn_branch_id)
                        ->exists();
                    if ($userBranches) {
                        $userstobenotified[] = $user;
                    }
                }
            }
            Notification::send($userstobenotified, new ServiceBookingNotification($serviceMessage));
            $usr = Auth::user();
            event(new BookingStatus($serviceMessage, $userstobenotified, $usr));

            // whatsApp message
            $customerContactInfo = CmnCustomer::where('id', $updateData->cmn_customer_id)->first();
            $whatsAppService = new WhatsAppService();
            $whatsAppService->sendMessage($customerContactInfo->phone_no, $customerContactInfo->full_name, $this->getServiceInvoice($updateData->sch_service_booking_info_id)->order_details->where('id', $bookingId)->first());

            // //SMS notification
            // $customerContactInfo = CmnCustomer::where('id', $updateData->cmn_customer_id)->select('phone_no')->first();
            // SmsNotificationRepository::sendNotification($customerContactInfo->phone_no, MessageType::ServiceCancel, [['key' => '{booking_number}', 'value' => $updateData->id]]);

            return $updateStatus;
        }
    }

    /**
     * emailNotify=1 for send service notification by email otherwise not send email
     */
    public function ChangeBookingStatus($bookingId, $status, $emailNotify = 0)
    {
        $updateData = SchServiceBooking::where('id', $bookingId)->first();
        if ($status == ServiceStatus::Done) {
            $booking = SchServiceBooking::where('sch_service_id', $updateData->sch_service_id)
                ->whereNotIn('id', [$updateData->id])
                ->where('date', $updateData->date)
                ->where('start_time', $updateData->start_time)
                ->get();

            $booking->each(function ($booking) {
                $booking->status = ServiceStatus::Cancel;
                $booking->save();
            });

            $updateData->paid_amount = $updateData->service_amount;
            $updateData->payment_status = 1;
        } elseif ($status == ServiceStatus::Pending) {
            $updateData->paid_amount = 0;
            $updateData->payment_status = 2;
        } elseif ($status == ServiceStatus::Approved) {
            $booking = SchServiceBooking::where('sch_service_id', $updateData->sch_service_id)
                ->whereNotIn('id', [$updateData->id])
                ->where('date', $updateData->date)
                ->where('start_time', $updateData->start_time)
                ->get();

            $booking->each(function ($booking) {
                $booking->status = ServiceStatus::Cancel;
                $booking->save();
            });

            $updateData->paid_amount = 0;
            $updateData->payment_status = 2;
        } elseif ($status == ServiceStatus::Processing) {
            $booking = SchServiceBooking::where('sch_service_id', $updateData->sch_service_id)
                ->whereNotIn('id', [$updateData->id])
                ->where('date', $updateData->date)
                ->where('start_time', $updateData->start_time)
                ->get();

            $booking->each(function ($booking) {
                $booking->status = ServiceStatus::Cancel;
                $booking->save();
            });
        }
        $updateData->status = $status;
        $updateData->updated_by = Auth::id();
        $updateStatus = $updateData->update();
        $serviceId = $updateData->sch_service_id;
        $cmn_branch_id = $updateData->cmn_branch_id;

        //send notification to user
        $serviceDate = new Carbon($updateData->service_date);
        $customer = CmnCustomer::where('id', $updateData->cmn_customer_id)->first();
        $user = User::where('id', $customer->user_id)->first();
        $user_name = "";
        if ($user) {
            $user_name = $user->name;
        } else {
            $user_name = $customer->full_name;
        }
        $serviceMessage = [
            'user_name' => $user_name,
            'message_subject' => 'Booking ' . UtilityRepository::serviceStatus($status) . ' Notification',
            'message_body' => 'Your service request is ' . UtilityRepository::serviceStatus($status) . '.',
            'booking_info' => ' Booking No#' .  $updateData->id . ', Service Date# ' . $serviceDate->format('D, M d, Y') . ' at ' . $updateData->start_time . ' to ' .  $updateData->end_time,
            'message_footer' => 'Thanks you for choosing our service.',
            'action_url' => url('/client-dashboard'),
            'message' => " تم تغيير حالة الحجز الخاص ب" . $user_name . ' إلي حالة ' . UtilityRepository::serviceStatus($status) . ' بواسطة ' . Auth::user()->name,
            'id' => $updateData->id
        ];
        // if ($emailNotify == 1) {
        //     if ($customer != null && $customer->user_id != null && UtilityRepository::isEmailConfigured()) {
        //         Notification::send($user, new ServiceBookingNotification($serviceMessage));
        //         if ($status == ServiceStatus::Done) {
        //             $serviceFeedback = $updateData->service_feedback()->create(['user_id' => $updateData->customer->user_id]);
        //             $serviceFeedback->hash_code = $serviceFeedback->genHash();
        //             $serviceFeedback->update();

        //             $requestForFeedback = [
        //                 'user_name' => $user->name,
        //                 'message_subject' => 'Request for rating service quality',
        //                 'message_body' => 'Thank you so much for taking our service please share your feedback.',
        //                 'booking_info' => ' Booking No#' .  $updateData->id . ', Service Date# ' . $serviceDate->format('D, M d, Y') . ' at ' . $updateData->start_time . ' to ' .  $updateData->end_time,
        //                 'message_footer' => 'Thanks you for choosing our service.',
        //                 'action_url' => route('site.client.service.feedback.post', $serviceFeedback->hash_code, true)
        //             ];
        //             Notification::send($user, new ServiceBookingFeedbackNotification($requestForFeedback));
        //         }
        //     }
        // }

        $currentUserId = Auth::id();
        $userstobenotified = [];
        $users = User::where('user_type', 1)->get();
        foreach ($users as $user) {
            if ($user->id == $currentUserId) {
                continue;
            }
            if ($user->is_sys_adm) {
                $userstobenotified[] = $user;
                continue;
            }
            if ($user->sch_employee_id == $serviceId) {
                $userstobenotified[] = $user;
            } elseif ($user->sch_employee_id == null) {
                $userBranches = SecUserBranch::where('user_id', $user->id)
                    ->where('cmn_branch_id', $cmn_branch_id)
                    ->exists();
                if ($userBranches) {
                    $userstobenotified[] = $user;
                }
            }
        }
        Notification::send($userstobenotified, new ServiceBookingNotification($serviceMessage));

        $usr = Auth::user();
        event(new BookingStatus($serviceMessage, $userstobenotified, $usr));

        $whatsAppService = new WhatsAppService();
        $whatsAppService->sendMessage($customer->phone_no, $customer->full_name, $this->getServiceInvoice($updateData->sch_service_booking_info_id)->order_details->where('id', $bookingId)->first());

        // //SMS notification
        // $customerContactInfo = CmnCustomer::where('id', $updateData->cmn_customer_id)->select('phone_no')->first();
        // SmsNotificationRepository::sendNotification(
        //     $customerContactInfo->phone_no,
        //     MessageType::ServiceStatus,
        //     [
        //         ['key' => '{booking_number}', 'value' => $updateData->id],
        //         ['key' => '{service_status}', 'value' => UtilityRepository::serviceStatus($status)],
        //         ['key' => '{service_date}', 'value' => $serviceDate->format('D, M d, Y')],
        //         ['key' => '{service_start}', 'value' => $updateData->start_time],
        //         ['key' => '{service_end}', 'value' => $updateData->end_time]
        //     ]
        // );
        return $updateStatus;
    }

    /**
     * emailNotify=1 for send service notification by email otherwise not send email
     */
    public function ChangeBookingStatusAndReturnBookingData($bookingId, $status, $emailNotify = 0)
    {
        $updateData = SchServiceBooking::where('id', $bookingId)->first();
        $branchId = $updateData->cmn_branch_id;
        $employeeId = $updateData->sch_employee_id;
        if ($status == ServiceStatus::Done) {
            $booking = SchServiceBooking::where('sch_service_id', $updateData->sch_service_id)
                ->whereNotIn('id', [$updateData->id])
                ->where('date', $updateData->date)
                ->where('start_time', $updateData->start_time)
                ->get();

            $booking->each(function ($booking) {
                $booking->status = ServiceStatus::Cancel;
                $booking->save();
            });

            $updateData->paid_amount = $updateData->service_amount;
            $updateData->payment_status = 1;
        } elseif ($status == ServiceStatus::Pending) {
            $updateData->paid_amount = 0;
            $updateData->payment_status = 2;
        } elseif ($status == ServiceStatus::Approved) {
            $booking = SchServiceBooking::where('sch_service_id', $updateData->sch_service_id)
                ->whereNotIn('id', [$updateData->id])
                ->where('date', $updateData->date)
                ->where('start_time', $updateData->start_time)
                ->get();

            $booking->each(function ($booking) {
                $booking->status = ServiceStatus::Cancel;
                $booking->save();
            });

            $updateData->paid_amount = 0;
            $updateData->payment_status = 2;
        } elseif ($status == ServiceStatus::Processing) {
            $booking = SchServiceBooking::where('sch_service_id', $updateData->sch_service_id)
                ->whereNotIn('id', [$updateData->id])
                ->where('date', $updateData->date)
                ->where('start_time', $updateData->start_time)
                ->get();

            $booking->each(function ($booking) {
                $booking->status = ServiceStatus::Cancel;
                $booking->save();
            });
        }
        $updateData->status = $status;
        $updateData->updated_by = Auth::id();
        $updateData->update();
        $bookingData = $this->getEmployeeBookingSchedule($branchId, $employeeId, 0, null, $bookingId);
        $serviceId = $updateData->sch_service_id;
        $cmn_branch_id = $updateData->cmn_branch_id;


        //send notification to user
        $serviceDate = new Carbon($updateData->service_date);
        $customer = CmnCustomer::where('id', $updateData->cmn_customer_id)->first();
        $user = User::where('id', $customer->user_id)->first();
        $user_name = "";
        if ($user) {
            $user_name = $user->name;
        } else {
            $user_name = $customer->full_name;
        }
        $serviceMessage = [
            'user_name' => $user_name,
            'message_subject' => 'Booking ' . UtilityRepository::serviceStatus($status) . ' Notification',
            'message_body' => 'Your service request is ' . UtilityRepository::serviceStatus($status) . '.',
            'booking_info' => ' Booking No#' .  $updateData->id . ', Service Date# ' . $serviceDate->format('D, M d, Y') . ' at ' . $updateData->start_time . ' to ' .  $updateData->end_time,
            'message_footer' => 'Thanks you for choosing our service.',
            'action_url' => url('/client-dashboard'),
            'message' => " تم تغيير حالة الحجز الخاص ب" . $user_name . ' إلي حالة ' . UtilityRepository::serviceStatus($status) . ' بواسطة ' . Auth::user()->name,
            'id' => $updateData->id
        ];
        // if ($emailNotify == '1') {
        //     if ($customer != null && $customer->user_id != null && UtilityRepository::isEmailConfigured()) {
        //         Notification::send($user, new ServiceBookingNotification($serviceMessage));
        //         // service feedback
        //         if ($status == ServiceStatus::Done) {
        //             $serviceFeedback = $updateData->service_feedback()->create(['user_id' => $updateData->customer->user_id]);
        //             $serviceFeedback->hash_code = $serviceFeedback->genHash();
        //             $serviceFeedback->update();

        //             $requestForFeedback = [
        //                 'user_name' => $user->name,
        //                 'message_subject' => 'Request for rating service quality',
        //                 'message_body' => 'Thank you so much for taking our service please share your feedback.',
        //                 'booking_info' => ' Booking No#' .  $updateData->id . ', Service Date# ' . $serviceDate->format('D, M d, Y') . ' at ' . $updateData->start_time . ' to ' .  $updateData->end_time,
        //                 'message_footer' => 'Thanks you for choosing our service.',
        //                 'action_url' => route('site.client.service.feedback.post', $serviceFeedback->hash_code, true)
        //             ];
        //             Notification::send($user, new ServiceBookingFeedbackNotification($requestForFeedback));
        //         }
        //     }
        // }
        $currentUserId = Auth::id();
        $userstobenotified = [];
        $users = User::where('user_type', 1)->get();
        foreach ($users as $user) {
            if ($user->id == $currentUserId) {
                continue;
            }
            if ($user->is_sys_adm) {
                $userstobenotified[] = $user;
                continue;
            }
            if ($user->sch_employee_id == $serviceId) {
                $userstobenotified[] = $user;
            } elseif ($user->sch_employee_id == null) {
                $userBranches = SecUserBranch::where('user_id', $user->id)
                    ->where('cmn_branch_id', $cmn_branch_id)
                    ->exists();
                if ($userBranches) {
                    $userstobenotified[] = $user;
                }
            }
        }
        Notification::send($userstobenotified, new ServiceBookingNotification($serviceMessage));

        $usr = Auth::user();
        event(new BookingStatus($serviceMessage, $userstobenotified, $usr));

        $whatsAppService = new WhatsAppService();
        $whatsAppService->sendMessage($customer->phone_no, $customer->full_name, $this->getServiceInvoice($updateData->sch_service_booking_info_id)->order_details->where('id', $bookingId)->first());

        // //SMS notification
        // $customerContactInfo = CmnCustomer::where('id', $updateData->cmn_customer_id)->select('phone_no')->first();
        // SmsNotificationRepository::sendNotification(
        //     $customerContactInfo->phone_no,
        //     MessageType::ServiceStatus,
        //     [
        //         ['key' => '{booking_number}', 'value' => $updateData->id],
        //         ['key' => '{service_status}', 'value' => UtilityRepository::serviceStatus($status)],
        //         ['key' => '{service_date}', 'value' => $serviceDate->format('D, M d, Y')],
        //         ['key' => '{service_start}', 'value' => $updateData->start_time],
        //         ['key' => '{service_end}', 'value' => $updateData->end_time]
        //     ]
        // );
        $bookingData['status_details'] = [
            'status_code' => $updateData->status,
            'status_description' => ServiceStatus::getDescription($updateData->status),
        ];
        return $bookingData;
    }

    public function getEmployeeBookingSchedule($branchId, $employeeId, $customerId = 0, $date = null, $serviceBookingId = 0, $serviceBbookingInfoId = 0)
    {

        $employee = SchEmployee::join('cmn_branches', 'sch_employees.cmn_branch_id', '=', 'cmn_branches.id')
            ->Leftjoin('hrm_designations', 'sch_employees.hrm_designation_id', '=', 'hrm_designations.id')
            ->where('cmn_branches.id', $branchId);
        if ($employeeId > 0)
            $employee = $employee->where('sch_employees.id', $employeeId);


        $employee = $employee->select(
            'sch_employees.id',
            'cmn_branches.name as branch',
            'sch_employees.full_name as employee',
            'hrm_designations.name as designation',
            'sch_employees.image_url'
        )->get();

        $bookingService = SchServiceBooking::UserWiseServiceBooking()->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
            ->join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id');

        // search by service booking id for (insert/update schedule)
        if ($serviceBookingId > 0) {
            $bookingService = $bookingService->where('sch_service_bookings.id', $serviceBookingId);
        } else if ($serviceBbookingInfoId > 0) {
            $bookingService = $bookingService->where('sch_service_bookings.sch_service_booking_info_id', $serviceBbookingInfoId);
        } else {
            $bookingService = $bookingService->where('sch_service_bookings.date', $date)
                ->whereIn('sch_service_bookings.sch_employee_id', $employee->pluck('id'));
        }

        if ($customerId != null && $customerId > 0)
            $bookingService = $bookingService->where('sch_service_bookings.cmn_customer_id', $customerId);

        $bookingService = $bookingService->select(
            'sch_service_bookings.sch_employee_id',
            'sch_service_bookings.id',
            'cmn_customers.full_name as customer',
            'sch_service_bookings.date',
            'sch_service_bookings.start_time',
            'sch_service_bookings.end_time',
            'sch_services.title as service',
            'sch_service_bookings.status'
        )->get();

        $serviceTimeSlot = CmnBusinessHour::selectRaw('min(start_time) as startTime,max(end_time) as endTime')->first();

        if ($serviceTimeSlot != null) {
            if ($serviceTimeSlot->startTime > $bookingService->min('start_time') && $bookingService->min('start_time') != null)
                $serviceTimeSlot['startTime'] = $bookingService->min('start_time');
            if ($serviceTimeSlot->endTime < $bookingService->min('end_time') && $bookingService->min('end_time') != null)
                $serviceTimeSlot['endTime'] = $bookingService->min('end_time');
        }

        $employee->each(function ($collection, $service) use ($bookingService) {
            $bookingArr = array();
            foreach ($bookingService->where('sch_employee_id', $collection->id) as $bookingData) {
                $bookingArr[] = $bookingData;
            }
            $collection->booking_service = $bookingArr;
        });
        return ['status' => '1', 'data' => $employee, 'serviceTimeSlot' => $serviceTimeSlot];
    }


    public function getService($serviceCatagoryId, $serviceVisibility = null)
    {
        $data = SchServices::select(
            'id',
            'title as name'
        )->where('sch_service_category_id', $serviceCatagoryId);
        if ($serviceVisibility != null) {
            $data = $data->where('visibility', $serviceVisibility);
        }
        $data = $data->get();
        return $data;
    }

    public function serviceIsAvaiableApi($serviceId, $employeeId, $date, $startTime, $endTime, $excludeCurrent = false, $bookingId = null)
    {
        \Log::info('Checking service availability', [
            'serviceId' => $serviceId,
            'employeeId' => $employeeId,
            'date' => $date,
            'startTime' => $startTime,
            'endTime' => $endTime,
            'excludeCurrent' => $excludeCurrent,
            'bookingId' => $bookingId
        ]);
        
        $query = SchServiceBooking::where('sch_service_id', $serviceId)
            ->where('sch_employee_id', $employeeId)
            ->where('date', $date)
            ->where(function ($q) use ($startTime, $endTime) {
                $q->where(function ($subQuery) use ($startTime, $endTime) {
                    $subQuery->where('start_time', '<', $endTime)
                             ->where('end_time', '>', $startTime);
                });
            });
    
        if ($excludeCurrent && $bookingId) {
            $query->where('id', '!=', $bookingId); // استثناء الحجز الحالي
        }
    
        return $query->count();
    }
    


    public function serviceIsAvaiable($serviceId, $employeeId, $date, $serviceStartTime, $serviceEndTime, $withLock = false)
    {
        $serviceStatus = [ServiceStatus::Approved, ServiceStatus::Done, ServiceStatus::Pending];
        $serviceCount = SchServiceBooking::where('sch_employee_id', $employeeId)
            // ->where('sch_service_id', $serviceId)
            ->where('date', $date)
            ->where('start_time', '=', $serviceStartTime)
            // ->where('start_time', '=', $serviceEndTime)
            // ->where('end_time', '>=', $serviceStartTime)
            ->whereIn('status', $serviceStatus);
        
        if ($withLock){
			$serviceCount = $serviceCount->lockForUpdate();
		}
        return $serviceCount->count();
    }

    /**
     * check service is available to booking
     */
    public function IsServiceLimitation($serviceDate, $serviceStartTime, $customerId, $serviceId, $checkServiceLimit, $checkBookingLimit)
    {

        $service = SchServices::where('id', $serviceId)
            ->select(
                'appoinntment_limit_type',
                'appoinntment_limit',
                'minimum_time_required_to_booking_in_days',
                'minimum_time_required_to_booking_in_time',
                'minimum_time_required_to_cancel_in_days',
                'minimum_time_required_to_cancel_in_time'
            )->first();
        $allowServiceLimit = 0;
        $allowBookingLimit = 0;
        if ($service != null) {

            //check service limit daily/monthly/weekly
            if ($checkServiceLimit == 1) {
                $serviceTo = new Carbon($serviceDate);
                $serviceFrom = new Carbon($serviceDate);

                if ($service->appoinntment_limit_type == AppointmentLimitType::Unlimited) {
                    $allowServiceLimit = 1;
                } else if ($service->appoinntment_limit_type == AppointmentLimitType::Daily) {
                    $serviceFrom->subDays(1);
                } else if ($service->appoinntment_limit_type == AppointmentLimitType::Weekly) {
                    $serviceFrom->subDays(7);
                } else if ($service->appoinntment_limit_type == AppointmentLimitType::Monthly) {
                    $serviceFrom->subDays(30);
                } else if ($service->appoinntment_limit_type == AppointmentLimitType::Yearly) {
                    $serviceFrom->subDays(365);
                } else if ($checkServiceLimit == 0) {
                    $serviceSts = [ServiceStatus::Done, ServiceStatus::Approved, ServiceStatus::Processing, ServiceStatus::Pending];
                    $serviceCount = SchServiceBooking::where('cmn_customer_id', $customerId)->where('sch_service_id', $serviceId)
                        ->where('date', '>=', $serviceFrom->format('Y-m-d'))->where('date', '<=', $serviceTo)
                        ->whereIn('status', $serviceSts)->count();
                    if ($serviceCount >= $service->appoinntment_limit) {
                        return ['allow' => 0, 'message' => "Service limit is exceed", 'for' => 'ServiceLimit'];
                    } else {
                        $allowServiceLimit = 1;
                    }
                }
            }
            if ($checkBookingLimit == 1) {
                //check service booking is available
                $nowDate = new Carbon();
                $selectedServiceDate = new Carbon($serviceDate . ' ' . $serviceStartTime);
                $minimumTimeRequiredToBookingInMinute = DateTimeRepository::TotalMinuteFromTime($service->minimum_time_required_to_booking_in_time);
                $serviceAvaiableFromBooking = $nowDate->addDays($service->minimum_time_required_to_booking_in_days)->addMinute($minimumTimeRequiredToBookingInMinute);

                if ($selectedServiceDate >= $serviceAvaiableFromBooking) {
                    $allowBookingLimit = 1;
                } else {
                    return ['allow' => 0, 'message' => "Need to booking service minimum " . $service->minimum_time_required_to_booking_in_days . ' days & ' . $minimumTimeRequiredToBookingInMinute . ' minute ago.', 'for' => 'ServiceBookingLimit'];
                }
            }
        }
        if ($allowBookingLimit == 1 || $allowServiceLimit == 1)
            return ['allow' => 1, 'message' => "Allow", 'for' => 'All'];
    }

    /**
     * Check service is available to cancel?
     */
    public function IsServiceAvailableToCancel($serviceBookingId)
    {
        $bookedService = SchServiceBooking::where('id', $serviceBookingId)->whereNotIn('status', [ServiceStatus::Done])
            ->select('sch_service_id', 'date')->first();
        if ($bookedService != null) {
            $service = SchServices::where('id', $bookedService->sch_service_id)
                ->select(
                    'minimum_time_required_to_cancel_in_days',
                    'minimum_time_required_to_cancel_in_time'
                )->first();

            //check service cancel limit
            if ($service != null) {
                $selectedServiceDate = new Carbon($bookedService->date);
                $nowDate = new Carbon();
                $minimumTimeRequiredToCancelInMinute = DateTimeRepository::TotalMinuteFromTime($service->minimum_time_required_to_cancel_in_time);
                $cancelAllowFromDate = $selectedServiceDate->addDays($service->minimum_time_required_to_cancel_in_days)->addMinute($minimumTimeRequiredToCancelInMinute);

                if ($cancelAllowFromDate >= $nowDate) {
                    //Allow to cancel service
                    return 1;
                } else {
                    throw new ErrorException("Need to cancel service minimum " . $service->minimum_time_required_to_cancel_in_days . ' days & ' . $minimumTimeRequiredToCancelInMinute . ' minute ago.', 400);
                }
            }
        }
        //Service / Service booking is empty"
        return 1;
    }

    /**
     * get service booking info
     */
    public function getBookingInfo($dateFrom, $dateTo, $bookingId, $employeeId, $customerId, $serviceStatus, $branchId)
    {
        $br = new Controller();
        $services = SchServiceBooking::UserWiseServiceBooking()
            ->join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
            ->join('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id')
            ->join('sch_employees', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
            ->whereIn('sch_service_bookings.cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
            ->when($bookingId, fn($query) => $query->where('sch_service_bookings.id', $bookingId))
            ->when(!$bookingId && $dateFrom && $dateTo, fn($query) => $query->whereBetween('sch_service_bookings.date', [$dateFrom, $dateTo]))
            ->when($employeeId, fn($query) => $query->where('sch_service_bookings.sch_employee_id', $employeeId))
            ->when($customerId, fn($query) => $query->where('sch_service_bookings.cmn_customer_id', $customerId))
            ->when($serviceStatus, fn($query) => $query->where('sch_service_bookings.status', $serviceStatus))
            ->when($branchId, fn($query) => $query->where('sch_service_bookings.cmn_branch_id', $branchId))
            ->selectRaw(
                'sch_service_bookings.id,
                sch_service_bookings.status,
                sch_service_bookings.payment_status,
                cmn_customers.full_name as customer,
                cmn_customers.phone_no as customer_phone_no,
                sch_employees.full_name as employee,
                cmn_branches.name as branch,
                sch_services.title as service,
                sch_service_bookings.date,
                sch_service_bookings.start_time,
                sch_service_bookings.end_time,
                sch_service_bookings.remarks,
                sch_service_bookings.service_amount,
                sch_service_bookings.paid_amount,
                sch_service_bookings.service_amount - sch_service_bookings.paid_amount as due'

            )
            ->orderByRaw('sch_service_bookings.date desc, start_time desc')
            ->get()
            ->map(fn($item) => [
                'id' => $item->id,
                'status' => $item->status,
                'statusName' => ServiceStatus::getDescription($item->status),
                'payment_status' => $item->payment_status,
                'paymentStatusName' => ServicePaymentStatus::getDescription($item->payment_status),
                'customer' => $item->customer,
                'customer_phone_no' => $item->customer_phone_no,
                'employee' => $item->employee,
                'branch' => $item->branch,
                'service' => $item->service,
                'date' => $item->date,
                'start_time' => $item->start_time,
                'end_time' => $item->end_time,
                'remarks' => $item->remarks,
                'service_amount' => $item->service_amount,
                'paid_amount' => $item->paid_amount,
                'due' => $item->due
            ]);
    
        return $services;
    }


     /**
     * get service booking info
     */
    public function getBookingInfoApi($dateFrom, $dateTo, $bookingId, $employeeId, $customerId, $serviceStatus, $branchId)
    {
        $br = new Controller();
        
        $services = SchServiceBooking::UserWiseServiceBooking()
            ->join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->join('cmn_customers', 'sch_service_bookings.cmn_customer_id', '=', 'cmn_customers.id')
            ->join('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id')
            ->join('sch_employees', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
            ->whereIn('sch_service_bookings.cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'))
            ->when($bookingId, fn($query) => $query->where('sch_service_bookings.id', $bookingId))
            ->when(!$bookingId && $dateFrom && $dateTo, fn($query) => $query->whereBetween('sch_service_bookings.date', [$dateFrom, $dateTo]))
            ->when($employeeId, fn($query) => $query->where('sch_service_bookings.sch_employee_id', $employeeId))
            ->when($customerId, fn($query) => $query->where('sch_service_bookings.cmn_customer_id', $customerId))
            ->when($serviceStatus, fn($query) => $query->where('sch_service_bookings.status', $serviceStatus))
            ->when($branchId, fn($query) => $query->where('sch_service_bookings.cmn_branch_id', $branchId))
            ->selectRaw(
                'sch_service_bookings.id,
                sch_service_bookings.status,
                sch_service_bookings.payment_status,
                cmn_customers.full_name as customer,
                cmn_customers.phone_no as customer_phone_no,
                sch_employees.full_name as employee,
                cmn_branches.name as branch,
                sch_services.title as service,
                sch_service_bookings.date,
                sch_service_bookings.start_time,
                sch_service_bookings.end_time,
                sch_service_bookings.remarks,
                sch_service_bookings.service_amount - sch_service_bookings.paid_amount as due'
            )
            ->orderByRaw('sch_service_bookings.date desc, start_time desc')
            ->get()
            ->map(fn($item) => [
                'id' => $item->id,
                'status' => $item->status,
                'statusName' => ServiceStatus::getDescription($item->status),
                'payment_status' => $item->payment_status,
                'customer' => $item->customer,
                'customer_phone_no' => $item->customer_phone_no,
                'employee' => $item->employee,
                'branch' => $item->branch,
                'service' => $item->service,
                'date' => $item->date,
                'start_time' => $item->start_time,
                'end_time' => $item->end_time,
                'remarks' => $item->remarks,
                'due' => $item->due
            ]);
    
        return $services;
    }
    

    

    /**
     * get employee service by service,branch,employee status like public,private,disable 
     * employeeStatus will be array like [1] or [1,2]  
     */
    public function getEmployeeByService($serviceId, $branchId, $employeeStatus)
    {
        $currency = CmnCurrencySetup::select('value')->first();
        $data = SchEmployeeService::join('sch_employees', 'sch_employee_services.sch_employee_id', '=', 'sch_employees.id')
            ->where('sch_employee_services.sch_service_id', $serviceId)
            ->where('sch_employees.cmn_branch_id', $branchId)
            ->where('sch_employee_services.status', 1)
            ->whereIn('sch_employees.status', $employeeStatus)
            ->select(
                'sch_employees.id',
                'sch_employees.full_name',
                'sch_employee_services.fees'
            )->get();

        $arr = array();
        foreach ($data as $val) {
            $arr[] = [
                'id' => $val['id'],
                'name' => $val['full_name'] . ' (' . $currency->value . '' . $val['fees'] . ')',
                'fees' => $val['fees'],
                'currency' => $currency->value
            ];
        }
        return $arr;
    }

    public function getServiceInvoice($orderId)
    {
        $orderInfo = SchServiceBookingInfo::join('cmn_customers', 'sch_service_booking_infos.cmn_customer_id', '=', 'cmn_customers.id')
            ->where('sch_service_booking_infos.id', $orderId)
            ->select(
                'sch_service_booking_infos.id',
                'sch_service_booking_infos.booking_date',
                'sch_service_booking_infos.total_amount',
                'sch_service_booking_infos.paid_amount',
                'sch_service_booking_infos.due_amount',
                'sch_service_booking_infos.coupon_code',
                'sch_service_booking_infos.coupon_discount',
                'sch_service_booking_infos.remarks',
                'sch_service_booking_infos.payable_amount',
                'cmn_customers.full_name',
                'cmn_customers.phone_no',
                // 'cmn_customers.email',
                'cmn_customers.street_address',
                'cmn_customers.state',
                'cmn_customers.city',
                'cmn_customers.street_number',
            )->first();

        $orderDetails = SchServiceBooking::where('sch_service_bookings.sch_service_booking_info_id', $orderId)->join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->join('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id')
            ->join('sch_employees', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
            ->selectRaw(
                'sch_service_bookings.id,
                sch_service_bookings.status,
                sch_employees.full_name as employee,
                cmn_branches.name as branch,
                cmn_branches.lat as branch_lat,
                cmn_branches.long as branch_long,
                sch_services.title as service,
                sch_service_bookings.date,
                sch_service_bookings.start_time,
                sch_service_bookings.end_time,
                sch_service_bookings.service_amount,
                sch_service_bookings.paid_amount,
                sch_service_bookings.service_amount-sch_service_bookings.paid_amount as due'
            )->orderByRaw('sch_service_bookings.date desc, start_time desc')->get();
        if ($orderInfo == [])
            return null;
        $orderInfo->order_details = $orderDetails;
        return $orderInfo;
    }
	

    public function addBookingPayment($bookingId, $due, $extra_input, $status, $emailNotify = 0)
    {
        try {
            $updateData = SchServiceBooking::where('id', $bookingId)->first();
            $paid_amount = ((float) ($updateData->paid_amount ?? 0)) + (float) $due;
            $service_amount = (float) $updateData->service_amount;
            
            $remaining_due = $service_amount - $paid_amount;
            $forgiven_amount = (float) ($extra_input ?? 0);
            $tolerance_amount = 0;
    
            if ($status == 0) {
                $tolerance_amount = $remaining_due; 
                $forgiven_amount += $tolerance_amount;
                $remaining_due = 0;
            } elseif ($status == 1) {
                $tolerance_amount = (float) $extra_input; 
                $forgiven_amount += $tolerance_amount;
                $remaining_due -= $tolerance_amount; 
            }
    
            $remaining_due = max(0, $remaining_due);
    
            $payment_status = $remaining_due > 0 ? ServicePaymentStatus::PartialPaid : ServicePaymentStatus::Paid;
            $updateData->paid_amount = $paid_amount + $tolerance_amount;
            $updateData->payment_status = $paid_amount > 0 ? $payment_status : ServicePaymentStatus::Unpaid;
            $updateData->status = $payment_status == ServicePaymentStatus::Paid ? ServiceStatus::Done : $updateData->status;
            $updateData->updated_by = Auth::id();
            
            $updateStatus = $updateData->update();
    
            if ($tolerance_amount > 0) {
                $BookingPaymentTolerance = new BookingPaymentTolerance();
                $BookingPaymentTolerance->booking_id = $bookingId;
                $BookingPaymentTolerance->allowed_amount = $tolerance_amount;
                $BookingPaymentTolerance->approved_by = auth()->user()->id;
                $BookingPaymentTolerance->save();
            }
    
            return $updateStatus;
        } catch (Exception $e) {
            Log::error('Booking Payment Error:', ['error' => $e->getMessage()]);
            return false;
        }
    }
    
    
	
	public function getServiceBookingInfo($branch_id = null, $is_monthly = null)
	{
		
        $bookingInfo = SchServiceBookingInfo::query()
            ->leftJoin('sch_service_bookings', 'sch_service_booking_infos.id', '=', 'sch_service_bookings.sch_service_booking_info_id')
            ->leftJoin('cmn_branches', 'sch_service_bookings.cmn_branch_id', '=', 'cmn_branches.id') // ربط الفروع
            ->withCount('serviceBookingsAll')
            ->selectRaw('sch_service_booking_infos.id,
                        sch_service_booking_infos.booking_date as date,
                        sch_service_bookings.start_time as start_time,
                        sch_service_bookings.end_time as end_time,
                        sch_service_booking_infos.is_monthly_active,
                        sch_service_booking_infos.is_monthly,
                        cmn_branches.name as branch_name' 
            )
            ->with('customer');
		
		if (!is_null($branch_id)){
            if (auth()->user()->is_sys_adm != 1) {
			$bookingInfo = $bookingInfo->where('sch_service_bookings.cmn_branch_id', '=', $branch_id);
            }      
        }
		if (!is_null($is_monthly)){
			$bookingInfo = $bookingInfo->where('sch_service_booking_infos.is_monthly','=', $is_monthly);
		}
		return $bookingInfo->orderByDesc('sch_service_booking_infos.id')->get()->unique();
	}

    public function getForgivingGenerous()
    {
        $forgivingGenerous = BookingPaymentTolerance::with([
            'booking' => function ($query) {
                $query->select('id', 'date','start_time', 'end_time', 'cmn_branch_id' , 'cmn_customer_id','sch_employee_id' ,'sch_service_id');
            },
            'booking.branch' => function ($query) {
                $query->select('id', 'name');
            },
            'booking.customer' => function ($query) {
                $query->select('id', 'full_name', 'phone_no');
            },
            'booking.employee' => function ($query) {
                $query->select('id', 'full_name');
            },
            'booking.service' => function ($query) {
                $query->select('id', 'title','sch_service_category_id');
            },
            'booking.service.category' => function ($query) {
                $query->select('id', 'name');
            }
        ]);
        if (auth()->user()->is_sys_adm != 1) {
            $forgivingGenerous->where('approved_by', Auth::id());
        }
        return $forgivingGenerous->get();
    }

    
	/**
	 * @throws Exception
	 */
	public function cancelBookingMonthly($id, $service_date)
	{
		$bookingInfo = SchServiceBookingInfo::query()->with('serviceBookingsAll' , function ($q) use ($service_date){
				$q->where('date', '>=', $service_date);
			})->where([
				'id' => $id,
				'is_monthly' => 1,
				'is_monthly_active' => 1
			])->first();
		
		if (!$bookingInfo){
			throw new Exception('هذا الحجز ليس شهرى نشط بعد الان! من فضلك تاكد وحاول مره اخرى');
		}
		
		$bookingInfo->update([
			'is_monthly_active' => 0
		]);
		
		$bookingInfo->serviceBookingsAll->each(function ($booking) {
			$booking->status = ServiceStatus::Cancel;
			$booking->update();
			$this->notifyUserBookingUpdate($booking);
		});
		
	}
	
	private function notifyUserBookingUpdate($updateData)
	{
		//send notification to user
		$serviceDate = new Carbon($updateData->service_date);
		$customer = CmnCustomer::where('id', $updateData->cmn_customer_id)->first();
		$user = User::where('id', $customer->user_id)->first();
		$status = $updateData->status;
		$serviceId = $updateData->sch_service_id;
		$cmn_branch_id = $updateData->cmn_branch_id;
		$bookingId = $updateData->id;
		$user_name = $user->name ?? $customer->full_name;
		$serviceMessage = [
			'user_name' => $user_name,
			'message_subject' => 'Booking ' . UtilityRepository::serviceStatus($status) . ' Notification',
			'message_body' => 'Your service request is ' . UtilityRepository::serviceStatus($status) . '.',
			'booking_info' => ' Booking No#' .  $updateData->id . ', Service Date# ' . $serviceDate->format('D, M d, Y') . ' at ' . $updateData->start_time . ' to ' .  $updateData->end_time,
			'message_footer' => 'Thanks you for choosing our service.',
			'action_url' => url('/client-dashboard'),
			'message' => " تم تغيير حالة الحجز الخاص ب" . $user_name . ' إلي حالة ' . UtilityRepository::serviceStatus($status) . ' بواسطة ' . Auth::user()->name,
			'id' => $updateData->id
		];
		// if ($emailNotify == '1') {
		//     if ($customer != null && $customer->user_id != null && UtilityRepository::isEmailConfigured()) {
		//         Notification::send($user, new ServiceBookingNotification($serviceMessage));
		//         // service feedback
		//         if ($status == ServiceStatus::Done) {
		//             $serviceFeedback = $updateData->service_feedback()->create(['user_id' => $updateData->customer->user_id]);
		//             $serviceFeedback->hash_code = $serviceFeedback->genHash();
		//             $serviceFeedback->update();
		
		//             $requestForFeedback = [
		//                 'user_name' => $user->name,
		//                 'message_subject' => 'Request for rating service quality',
		//                 'message_body' => 'Thank you so much for taking our service please share your feedback.',
		//                 'booking_info' => ' Booking No#' .  $updateData->id . ', Service Date# ' . $serviceDate->format('D, M d, Y') . ' at ' . $updateData->start_time . ' to ' .  $updateData->end_time,
		//                 'message_footer' => 'Thanks you for choosing our service.',
		//                 'action_url' => route('site.client.service.feedback.post', $serviceFeedback->hash_code, true)
		//             ];
		//             Notification::send($user, new ServiceBookingFeedbackNotification($requestForFeedback));
		//         }
		//     }
		// }
		$currentUserId = Auth::id();
		$userstobenotified = [];
		$users = User::where('user_type', 1)->get();
		foreach ($users as $user) {
			if ($user->id == $currentUserId) {
				continue;
			}
			if ($user->is_sys_adm) {
				$userstobenotified[] = $user;
				continue;
			}
			if ($user->sch_employee_id == $serviceId) {
				$userstobenotified[] = $user;
			} elseif ($user->sch_employee_id == null) {
				$userBranches = SecUserBranch::where('user_id', $user->id)
					->where('cmn_branch_id', $cmn_branch_id)
					->exists();
				if ($userBranches) {
					$userstobenotified[] = $user;
				}
			}
		}
		Notification::send($userstobenotified, new ServiceBookingNotification($serviceMessage));
		
		$usr = Auth::user();
		event(new BookingStatus($serviceMessage, $userstobenotified, $usr));
		
		$whatsAppService = new WhatsAppService();
		$whatsAppService->sendMessage($customer->phone_no, $customer->full_name, $this->getServiceInvoice($updateData->sch_service_booking_info_id)->order_details->where('id', $bookingId)->first());
		
	}

    public function onlinePayment($dateFrom, $dateTo, $branch_id)
    {
        $updated = SchServiceBooking::where('cmn_payment_type_id', 4)
            ->where('date', '>=', $dateFrom)
            ->where('date', '<=', $dateTo)
            ->where('cmn_branch_id', $branch_id)
            ->update(['paid_amount' => \DB::raw('service_amount') , 'online_done' => true]); 
            return true;
    }
}
