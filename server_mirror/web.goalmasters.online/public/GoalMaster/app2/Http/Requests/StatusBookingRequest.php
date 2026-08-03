<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StatusBookingRequest extends BaseFormRequest
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
            'status' => 'required|in:0,1,2,3,4',
            'booking_id' => 'required|exists:sch_service_bookings,id',
        ];
    }
}
