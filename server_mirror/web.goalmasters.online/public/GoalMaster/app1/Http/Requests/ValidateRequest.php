<?php

namespace App\Http\Requests;

class ValidateRequest extends BaseFormRequest
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
            'code' => 'sometimes|required|numeric|digits:6',
            'phone' => 'required|numeric|regex:/^09[0-9]{8}$/|exists:cmn_customers,phone_no',
            'forget' => 'sometimes|required|boolean:true',
        ];
    }

}
