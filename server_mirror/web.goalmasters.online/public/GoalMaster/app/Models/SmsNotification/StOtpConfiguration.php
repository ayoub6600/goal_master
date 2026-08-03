<?php

namespace App\Models\SmsNotification;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StOtpConfiguration extends Model
{
    protected $fillable = [
        'id',
        'name',
        'sms_gateway',
        'status',
        'created_by',
        'updated_by',
    ];
}
