<?php

namespace App\Models\Employee;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SchEmployeeService extends Model
{
    protected $fillable = [
        'id',
        'sch_employee_id',
        'sch_service_id',
        'fees',
        'status',
        'created_by',
        'updated_by'

    ];

    public function employee()
    {
        return $this->belongsTo(SecEmployee::class);
    }
}
