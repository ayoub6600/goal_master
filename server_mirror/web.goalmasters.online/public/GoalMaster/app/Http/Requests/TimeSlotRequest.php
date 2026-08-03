<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class TimeSlotRequest extends BaseFormRequest
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
            'date' => 'required|date|after_or_equal:today',
            'branch_id' => 'required|exists:cmn_branches,id',
            'service_id' => 'required|exists:sch_services,id',
            'employee_id' => 'required|exists:sch_employees,id',
        ];
    }
}
