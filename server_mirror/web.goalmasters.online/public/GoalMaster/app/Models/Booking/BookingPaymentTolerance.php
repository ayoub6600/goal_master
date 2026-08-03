<?php

namespace App\Models\Booking;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use App\Models\Booking\SchServiceBooking;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class BookingPaymentTolerance extends Model
{
    use HasFactory;

    protected $fillable = ['booking_id', 'allowed_amount', 'approved_by'];
    /**
     * 
     */
    public function booking()
    {
        return $this->belongsTo(SchServiceBooking::class, 'booking_id');
    }

    
    /**
     * 
     */
    public function approvedBy()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
