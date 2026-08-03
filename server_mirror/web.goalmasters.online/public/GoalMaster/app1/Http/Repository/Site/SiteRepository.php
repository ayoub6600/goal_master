<?php

namespace App\Http\Repository\Site;

use App\Enums\AppointmentLimitType;
use App\Enums\ServiceVisibility;
use App\Http\Repository\DateTimeRepository;
use App\Http\Repository\Settings\SettingsRepository;
use App\Models\Booking\SchServiceBookingFeedback;
use App\Models\Employee\SchEmployee;
use App\Models\Employee\SchEmployeeService;
use App\Models\Services\SchServices;

class SiteRepository
{
    public function getSiteServiceByServiceId($serviceId)
    {
        $stRepo = new SettingsRepository();
        $siteRepo=new SiteRepository();
        $data =  SchServices::where('id', $serviceId)->select('title', 'image', 'price', 'remarks', 'time_slot_in_time', 'appoinntment_limit', 'appoinntment_limit_type', 'visibility')->first();
        $currency = $stRepo->cmnCurrency();
        $data['time_slot_in_time'] = DateTimeRepository::TotalMinuteFromTime($data->time_slot_in_time);
        if ((int)$data->appoinntment_limit_type == AppointmentLimitType::Unlimited) {
            $data['appoinntment_limit'] = AppointmentLimitType::fromValue((int)$data->appoinntment_limit_type)->description;
        }
        $data['appoinntment_limit_type'] = AppointmentLimitType::fromValue((int)$data->appoinntment_limit_type)->description;
        if ($data->visibility == ServiceVisibility::PrivateService) {
            $data["visibility"] = "Call for service booking";
        } else {
            $data["visibility"] = "Online booking available";
        }
        $data['price'] = $currency . $data->price;
        $data['service_rating']=$siteRepo->getServiceFeedback($serviceId);
        return $data;
    }

    public function getEmployeeWiseServiceDetails($employeeId)
    {
        $stRepo = new SettingsRepository();
        $currency = $stRepo->cmnCurrency();
        $employee = SchEmployee::join('cmn_branches','sch_employees.cmn_branch_id','=','cmn_branches.id')
        ->where('sch_employees.status', 1)->where('sch_employees.id', $employeeId)
        ->select('sch_employees.id',
         'sch_employees.full_name', 
         'sch_employees.image_url', 
         'sch_employees.specialist',
         'cmn_branches.name as branch')->first();

        $services = SchEmployeeService::join('sch_services', 'sch_employee_services.sch_service_id', '=', 'sch_services.id')
            ->where('sch_employee_services.sch_employee_id', $employee->id)
            ->where('sch_employee_services.status', 1)
            ->select('sch_services.id','sch_services.title', 'sch_employee_services.fees', 'sch_services.image','sch_services.remarks')->get();
        foreach ($services as $service) {
            $service['fees'] = $currency . $service->fees;
        }
        $employee->services = $services;

        return $employee;
    }

    public function getExpertiseEmployee()
    {
        $data = SchEmployee::leftJoin('hrm_departments', 'sch_employees.hrm_department_id', '=', 'hrm_departments.id')
            ->select('sch_employees.full_name', 'sch_employees.image_url', 'hrm_departments.name as department', 'sch_employees.specialist')
            ->inRandomOrder()->limit(10)->get();
        return $data;
    }

    public function getServiceFeedback($serviceId){
        $data=SchServiceBookingFeedback::join('sch_service_bookings','sch_service_booking_feedback.sch_service_booking_id','=','sch_service_bookings.id')
        ->join('cmn_customers','sch_service_bookings.cmn_customer_id','=','cmn_customers.id')
        ->where('sch_service_bookings.sch_service_id',$serviceId)->where('sch_service_booking_feedback.status',1)
        ->select('cmn_customers.full_name','sch_service_booking_feedback.rating','sch_service_booking_feedback.feedback')->orderByRaw('sch_service_booking_feedback.created_at desc')->get();
        return $data;
    }
}
