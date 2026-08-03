<?php

namespace App\Models\SmsNotification;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StOtpMessage extends Model
{
    protected $fillable = [
        'id',
        'message_type', //enum
        'message_for',//cancel/done
        'tags',
        'message',
        'status',
        'created_by',
        'updated_by',
    ];
}
