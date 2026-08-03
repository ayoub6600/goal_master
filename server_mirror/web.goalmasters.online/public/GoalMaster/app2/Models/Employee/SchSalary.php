<?php

namespace App\Models\Employee;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SchSalary extends Model
{
    use HasFactory;

    public $fillable = [
        'sch_employee_id',
        'year',
        'month',
        'basic_salary',
        'total_service',
        'total_service_amount',
        'commission',
        'commission_amount',
        'pay_commission_based_on',
        'addition',
        'total_salary',
        'deduction',
        'netpay',
        'is_paid',
        'paid_at',
        'created_by',
        'updated_by',
    ];

    public function employee(){
        return $this->belongsTo('App\Models\Employee\SchEmployee', 'sch_employee_id');
    }
}
