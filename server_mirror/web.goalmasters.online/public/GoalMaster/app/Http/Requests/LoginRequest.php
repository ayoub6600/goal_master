<?php

namespace App\Http\Requests;


class LoginRequest extends BaseFormRequest
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
        logger($this->all());
        return [
            'username' => 'sometimes|required_without:phone_number|exists:users,username|prohibited_unless:phone_number,null',
            'phone_number' => 'sometimes|required_without:username|exists:users,phone_number|regex:/^09[0-9]{8}$/|prohibited_unless:username,null',
            'password' => 'required|min:8',
        ];
    }
        
    
}
