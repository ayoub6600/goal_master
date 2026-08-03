<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnBusinessHoliday extends Model
{
    protected $fillable = [
        'id',
        'cmn_branch_id',
        'title',
        'start_date',
        'end_date',
        'created_by',
        'updated_by'
    ];

    public function branch()
    {
        return $this->belongsTo(CmnBranch::class);
    }
}
