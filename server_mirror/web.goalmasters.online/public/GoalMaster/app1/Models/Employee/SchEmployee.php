<?php

namespace App\Models\Employee;

use App\Models\User;
use App\Models\Settings\CmnBranch;
use App\Http\Controllers\Controller;
use App\Models\Settings\HrmDesignation;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SchEmployee extends Model
{
    protected $fillable = [
        'id',
        'user_id',
        'image_url',
        'employee_id',
        'cmn_branch_id',
        'full_name',
        'email_address',
        'country_code',
        'contact_no',
        'present_address',
        'permanent_address',
        'gender',
        'dob',
        'hrm_department_id',
        'hrm_designation_id',
        'specialist',
        'note',
        'salary',
        'commission',
        'pay_commission_based_on',
        'target_service_amount',
        'id_card',
        'passport',
        'status',
        'created_by',
        'updated_by'
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    public function branch()
    {
        return $this->belongsTo(CmnBranch::class,'cmn_branch_id');
    }
    public function scopeUserEmployees($query)
    {
        $br = new Controller();
        $employeeId = auth()->user()->sch_employee_id;
        if ($employeeId != null)
            return $query->where('id', $employeeId);
        return $query->whereIn('cmn_branch_id', $br->getUserBranch()->pluck('cmn_branch_id'));
    }
    
    public function schedules()
    {
        return $this->hasMany(SchEmployeeSchedule::class, 'sch_employee_id');
    }

    public function designation()
    {
        return $this->belongsTo(HrmDesignation::class, 'hrm_designation_id');
    }
}
