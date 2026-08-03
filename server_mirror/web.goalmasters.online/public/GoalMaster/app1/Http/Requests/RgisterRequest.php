<?php

namespace App\Http\Requests;

use App\Enums\UserType;

class RgisterRequest extends BaseFormRequest
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
            'name' => 'required|min:5|max:255',
            'username' => 'required|unique:users,username|min:5|max:255',
            'password' => 'required|min:8|confirmed',
            'phone_number' => 'required|numeric|unique:users,phone_number|regex:/^09[0-9]{8}$/',
            'status' => 'integer',
            'user_type' => 'integer',
        ];
    }


    protected function prepareForValidation()
    {
        $this->merge([
            'status' => 1,
            'user_type' => UserType::WebsiteUser,
            // 'password' => Hash::make($this->password),
        ]);
    }

    
}
