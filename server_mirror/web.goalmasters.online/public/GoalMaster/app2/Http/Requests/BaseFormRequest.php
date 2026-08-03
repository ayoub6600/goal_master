<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class BaseFormRequest extends FormRequest
{
    /**
     * Customize the failed validation response.
     *
     * @param  \Illuminate\Contracts\Validation\Validator  $validator
     * @return void
     * @throws \Illuminate\Http\Exceptions\HttpResponseException
     */
    protected function failedValidation(Validator $validator)
    {
        $errors = $validator->errors()->toArray();

        $customErrors = [];
        foreach ($errors as $field => $messages) {
            $customErrors[$field] = array_map(function ($message) {
                return __("apiValidation.$message");
            }, $messages);
        }

        throw new HttpResponseException(response()->json([
            'success' => false,
            'message' => __('apiValidation.validation_errors'),
            'errors' => $customErrors,
        ], 422));
    }
}
