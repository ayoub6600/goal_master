<?php

namespace App\Http\Requests;


class ChangePasswordRequest extends BaseFormRequest
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
            'reset_token' => 'sometimes|required|string|exists:users,reset_token',
            'old_password' => 'sometimes|required|min:8|max:35',
            'password' => 'required|min:8|confirmed',
        ];
    }


}
