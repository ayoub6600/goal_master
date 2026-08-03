<?php

namespace App\Http\Requests;

use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends BaseFormRequest
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
        $userId = Auth::guard('api')->id();
        return [
            'name' => 'required|min:5|max:255',
            'username' => ['required','min:5','max:255',
                Rule::unique('users', 'username')->ignore($userId),
            ],
            'phone_number' => ['required','numeric','regex:/^09[0-9]{8}$/',
                Rule::unique('users', 'phone_number')->ignore($userId),
            ],
        ];
    }

}
