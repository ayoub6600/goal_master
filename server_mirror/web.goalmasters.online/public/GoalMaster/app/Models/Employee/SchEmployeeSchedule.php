<?php

namespace App\Models\Employee;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SchEmployeeSchedule extends Model
{
    protected $fillable = [
        'id',
        'sch_employee_id',
        'day',
        'start_time',
        'end_time',
        'break_start_time',
        'break_end_time',
        'is_off_day',
        'created_by',
        'updated_by'

    ];
    public function employees()
    {
        return $this->belongsTo(SchEmployee::class);
    }
}
