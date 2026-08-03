<?php

namespace App\Models\Payment;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnStripeApiConfig extends Model
{
    use HasFactory;
    protected $fillable = [
        'id',
        'cmn_payment_type_id',
        'api_key',
        'api_secret',
        'charge_type',
        'charge_percentage'
    ];
}
