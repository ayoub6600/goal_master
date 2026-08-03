<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreBookingRequest extends BaseFormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, mixed>
     */
    public function rules()
    {
        return [
            'branch_id' => 'required|exists:cmn_branches,id',
            'service_id' => 'required|exists:sch_services,id',
            'employee_id' => 'required|exists:sch_employees,id',
            'payment_type' => 'required|exists:cmn_payment_types,id',
            'full_name' => 'required|string|max:255',
            'phone_no' => ['required', 'string', 'max:20','regex:/^09[0-9]{8}$/'],
            'state' => 'required|in:1,2',
            'postal_code' => 'nullable|string|max:10',
            'city' => 'nullable|string|max:100',
            'street_address' => 'nullable|string|max:255',
            'start_time' => 'required|date_format:H:i:s',
            'end_time' => 'required|date_format:H:i:s',
            'service_date' => 'required|date|after_or_equal:today',
            'coupon_code' => 'sometimes|string|max:255',
        ];
    }
}
