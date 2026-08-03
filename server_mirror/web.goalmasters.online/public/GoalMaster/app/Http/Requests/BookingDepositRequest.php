<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\Validator;

class BookingDepositRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'booking_id'     => 'required|exists:sch_service_bookings,id',
            'payment_status' => 'required|in:0,1',
            'extra_input'    => ['nullable', 'numeric', 'min:0'],
            'due'            => ['required', 'numeric', 'min:1'],
        ];
    }

    public function messages(): array
    {
        return [
            'booking_id.required'     => $this->translate('booking_id_required'),
            'booking_id.exists'       => $this->translate('booking_id_invalid'),
            'payment_status.required' => $this->translate('payment_status_required'),
            'payment_status.in'       => $this->translate('payment_status_invalid'),
            'extra_input.numeric'     => $this->translate('extra_input_numeric'),
            'extra_input.min'         => $this->translate('extra_input_min'),
            'due.required'            => $this->translate('due_required'),
            'due.numeric'             => $this->translate('due_numeric'),
            'due.min'                 => $this->translate('due_min'),
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function ($validator) {
            $bookingId = $this->input('booking_id');

            if (!$bookingId) {
                return;
            }

            try {
                $booking = DB::table('sch_service_bookings')
                    ->where('id', $bookingId)
                    ->first();

                if ($booking) {
                    $maxAmount = (float) $booking->service_amount;

                    Log::info('Validation Check:', [
                        'booking_id' => $bookingId,
                        'maxAmount'  => $maxAmount,
                        'due'        => $this->input('due'),
                        'extra_input'=> $this->input('extra_input'),
                    ]);

                    $this->validateMaxValue($validator, 'due', $maxAmount);
                    
                    if ($this->has('extra_input')) {
                        $this->validateMaxValue($validator, 'extra_input', $maxAmount);
                    }
                }
            } catch (\Exception $e) {
                Log::error('Database error in BookingDepositRequest: ' . $e->getMessage());
                $validator->errors()->add('server', $this->translate('server_error'));
            }
        });
    }

    private function validateMaxValue(Validator $validator, string $field, float $maxAmount): void
    {
        $value = $this->input($field);
    
        if ($value !== null && $value > $maxAmount) 
            $validator->errors()->add($field, $this->translate($field . '_exceeded', ['maxAmount' => number_format($maxAmount, 2)]));
    }
    
    
    private function translate(string $key, array $params = []): string
    {
        $translations = [
            'en' => [
                'booking_id_required'     => 'The booking ID is required.',
                'booking_id_invalid'      => 'The selected booking ID is invalid.',
                'payment_status_required' => 'The payment status is required.',
                'payment_status_invalid'  => 'The selected payment status is invalid.',
                'extra_input_numeric'     => 'The extra input must be a number.',
                'extra_input_min'         => 'The extra input must be at least 0.',
                'due_required'            => 'The due amount is required.',
                'due_numeric'             => 'The due amount must be a number.',
                'due_min'                 => 'The due amount must be at least 1.',
                'due_exceeded'            => 'The Due amount cannot exceed the maximum allowed value: :maxAmount.',
                'extra_input_exceeded'    => 'The Extra input cannot exceed the maximum allowed value: :maxAmount.',
                'server_error'            => 'An error occurred on the server. Please try again later.',
            ],
            'ar' => [
                'booking_id_required'     => 'رقم الحجز مطلوب.',
                'booking_id_invalid'      => 'رقم الحجز المحدد غير صالح.',
                'payment_status_required' => 'حالة الدفع مطلوبة.',
                'payment_status_invalid'  => 'حالة الدفع المحددة غير صالحة.',
                'extra_input_numeric'     => 'يجب أن يكون الإدخال الإضافي رقمًا.',
                'extra_input_min'         => 'يجب أن يكون الإدخال الإضافي على الأقل 0.',
                'due_required'            => 'المبلغ المستحق مطلوب.',
                'due_numeric'             => 'يجب أن يكون المبلغ المستحق رقمًا.',
                'due_min'                 => 'يجب أن يكون المبلغ المستحق على الأقل 1.',
                'due_exceeded'            => 'المبلغ المستحق لا يمكن أن يتجاوز الحد الأقصى المسموح به: :maxAmount.',
                'extra_input_exceeded'    => 'المبلغ الإضافي لا يمكن أن يتجاوز الحد الأقصى المسموح به: :maxAmount.',
                'server_error'            => 'حدث خطأ في الخادم. يرجى المحاولة لاحقًا.',
            ],
        ];

        $lang = app()->getLocale() === 'ar' ? 'ar' : 'en';
        $message = $translations[$lang][$key] ?? $key;

        foreach ($params as $param => $value) {
            $message = str_replace(':' . $param, $value, $message);
        }

        return $message;
    }
}
