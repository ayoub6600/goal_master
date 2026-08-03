<?php

namespace App\Models\Booking;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Booking\SchServiceBooking;
use App\Models\User;

class SchServiceBookingFeedback extends Model
{
    use HasFactory;

    protected $fillable = [
        'sch_service_booking_id',
        'user_id',
        'hash_code',
        'rating',
        'feedback',
        'status'
    ];

    public function booking(){
        return $this->belongsTo(SchServiceBooking::class,'sch_service_booking_id');
    }

    public function user(){
        return $this->belongsTo(User::class,'user_id');
    }

    public function genHash(){
        return md5(str_pad($this->id.$this->sch_service_booking_id, 8, 0, STR_PAD_RIGHT));
    }

}

