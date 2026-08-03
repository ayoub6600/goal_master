<?php

namespace App\Models\Services;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SchServices extends Model
{
    protected $fillable = [
        'id',
        'title',
        'image',
        'sch_service_category_id',
        'visibility',
        'price',
        'duration_in_days',
        'duration_in_time',
        'time_slot_in_time',
        'padding_time_before',
        'padding_time_after',
        'appoinntment_limit_type',
        'appoinntment_limit',
        'minimum_time_required_to_booking_in_days',
        'minimum_time_required_to_booking_in_time',
        'minimum_time_required_to_cancel_in_days',
        'minimum_time_required_to_cancel_in_time',
        'remarks',
        'created_by',
        'updated_by'
    ];

    public function category()
    {
        return $this->belongsTo(SchServiceCategory::class, 'sch_service_category_id');
    }
}
