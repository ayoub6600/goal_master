<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnBusinessHour extends Model
{
    protected $fillable = [
        'id',
        'day',
        'start_time',
        'end_time',
        'cmn_branch_id',
        'is_off_day',
        'updated_by',
        'created_by'
    ];
}
