<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnCoupon extends Model
{
    use HasFactory;
    
    public $fillable = [
        'code',
        'image',
        'start_date',
        'end_date',
        'percent',
        'coupon_type',
        'use_limit',
        'min_order_value',
        'max_discount_value',
        'is_fixed',
        'user_id',
        'status',
        'created_by',
        'updated_by'
    ];

    public function customer(){
        return $this->belongsTo('App\Models\Customer\CmnCustomer','user_id');
    }

    protected $casts = [
        'start_date' => 'datetime',
        'end_date' => 'datetime',
    ];

    protected $appends = ['start_date_input', 'end_date_input', 'start_date_show', 'end_date_show'];

    public function getStartDateInputAttribute()
    {
        return $this->start_date->format('Y-m-d\TH:i:s');
    }

    public function getEndDateInputAttribute()
    {
        return $this->end_date->format('Y-m-d\TH:i:s');
    }

    public function getStartDateShowAttribute()
    {
        return $this->start_date->format('Y-m-d H:i:s');
    }

    public function getEndDateShowAttribute()
    {
        return $this->end_date->format('Y-m-d H:i:s');
    }
}
