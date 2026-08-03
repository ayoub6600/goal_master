<?php
namespace App\Models\Services;
use App\Models\Settings\CmnBranch;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SchServiceCategory extends Model
{
 protected $fillable = [
        'id',
        'name',
        'cmn_branch_id',
        'created_by',
        'modified_by',
    ];
    
    
    public function CmnBranch()
    {
        return $this->belongsTo(CmnBranch::class , 'cmn_branch_id' );
    }

    public function services()
    {
        return $this->hasMany(SchServices::class, 'sch_service_category_id');
    }
}
 