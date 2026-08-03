<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class FilterRequest extends BaseFormRequest
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
            'branch' => "filled|integer|exists:cmn_branches,id",
            'start_time' => "filled|date_format:H:i:s",
            'end_time' => "filled|date_format:H:i:s",
            'booking_start' => "required|date_format:Y-m-d",
            'booking_end' => "required|date_format:Y-m-d",
            'category_id' => "filled|integer|exists:sch_service_categories,id",
        ];
    }
    
}
