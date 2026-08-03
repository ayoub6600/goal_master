<?php

namespace App\Models\Payment;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnPaymentInfo extends Model
{
    protected $fillable = [
        'id',
        'order_id',
        'paymentable_id',
        'paymentable_type',
        'payment_type',
        'payment_amount',
        'payment_fee',
        'currency_code',
        'payee_email_address',
        'payee_crd_no',
        'payment_create_time',
        'payment_details'

    ];

    public function paymentable(){
		return $this->morphTo();
	}
}
