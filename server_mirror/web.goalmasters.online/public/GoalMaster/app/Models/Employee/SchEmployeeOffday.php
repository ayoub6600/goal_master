<?php

namespace App\Models\Employee;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SchEmployeeOffday extends Model
{
    protected $fillable = [
        'id',
        'sch_employee_id',
        'start_date',
        'end_date',
        'title',
        'created_by',
        'updated_by'

    ];
    public function employee()
    {
        return $this->belongsTo(SchEmployee::class);
    }
}
