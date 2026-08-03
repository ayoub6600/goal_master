<?php

namespace App\Models\Booking;

use App\Models\Customer\CmnCustomer;
use App\Models\Payment\CmnPaymentInfo;
use Illuminate\Database\Eloquent\Model;

class SchServiceBookingInfo extends Model
{
    protected $fillable = [
        'id',
        'booking_date',
        'total_amount',
        'paid_amount',
        'due_amount',
        'is_due_paid',
        'coupon_code',
        'coupon_discount',
        'remarks',
        'created_by',
        'updated_by',
        'cmn_customer_id',
        'payable_amount',
		'is_monthly',
		'is_monthly_active',
    ];

    public function customer()
    {
        return $this->belongsTo(CmnCustomer::class, 'cmn_customer_id');
    }
    public function serviceBookings()
    {
        return $this->belongsToMany(SchServiceBooking::class,"sch_service_bookings","sch_service_booking_info_id","id");
    }
	
	public function serviceBookingsAll()
	{
		return $this->hasMany(SchServiceBooking::class,"sch_service_booking_info_id","id");
	}

    public function payments()
    {
        return $this->morphMany(CmnPaymentInfo::class, "paymentable");
    }
}
