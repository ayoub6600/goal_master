<?php

namespace App\Models\SmsNotification;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnTwilioConfig extends Model
{
    protected $fillable = [
        'id',
        'sid',
        'token',
        'phone_no',
        'status',
        'created_by',
        'updated_by',
    ];
}
