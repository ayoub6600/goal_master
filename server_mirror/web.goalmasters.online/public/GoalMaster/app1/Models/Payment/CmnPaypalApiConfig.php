<?php

namespace App\Models\Payment;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnPaypalApiConfig extends Model
{
    protected $fillable = [
        'id',
        'cmn_payment_type_id',
        'client_id',
        'client_secret',
        'sandbox',
        'charge_type',
        'charge_percentage'
    ];

}
