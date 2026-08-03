<?php

namespace App\Models\Payment;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnPaymentType extends Model
{
    protected $fillable = [
        'id',
        'name',
        'type',
        'order',
        'status',
        'created_by',
        'modified_by',
    ];

}
