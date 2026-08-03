<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBookingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // تأكد من أنك تضيف صلاحيات التحكم إذا لزم الأمر
    }

    public function rules(): array
    {
        return [
            'id' => ['required', 'integer', 'exists:sch_service_bookings,id'],
            'cmn_branch_id' => ['required', 'integer', 'exists:cmn_branches,id'],
            'cmn_customer_id' => ['required', 'integer', 'exists:cmn_customers,id'],
            'sch_employee_id' => ['required', 'integer', 'exists:sch_employees,id'],
            'sch_service_id' => ['required', 'integer', 'exists:sch_services,id'],
            'service_date' => ['required', 'date', 'after_or_equal:today'],
            'service_time' => ['required', 'regex:/^\d{2}:\d{2}-\d{2}:\d{2}$/'],
            'status' => ['required', 'string', 'in:1,2,3,4'],
            'paid_amount' => ['required', 'numeric', 'min:0'],
            'cmn_payment_type_id' => ['required', 'integer', 'exists:cmn_payment_types,id'],
            'isForceBooking' => ['required', 'boolean'],
            'remarks' => ['nullable', 'string', 'max:500'],
        ];
    }
}
