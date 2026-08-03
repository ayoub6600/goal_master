<?php

namespace App\Models\Settings;

use App\Models\Zone;
use App\Http\Controllers\Controller;
use Illuminate\Database\Eloquent\Model;
use App\Models\Services\SchServiceCategory;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class CmnBranch extends Model
{
    protected $fillable = [
        'id',
        'name',
        'phone',
        'email',
        'address',
        'order',
        'status',
        'lat',
        'long',
        'zone_id',
        'created_by',
        'updated_by'
    ];
	
	public function getMapUrlAttribute($value): string
	{
		return '<a href="https://www.google.com/maps/search/?api=1&query=$this->lat,$this->long"> Location</a>';
	}
	
    public function scopeUserBranches($query)
    {
        $br=new Controller();
        return $query->whereIn('cmn_branches.id',$br->getUserBranch()->pluck('cmn_branch_id'));
    }
    
    public function schServiceCategories()
    {
        return $this->hasMany(SchServiceCategory::class, 'cmn_branch_id');
    }    
    
    public function zone()
    {
        return $this->belongsTo(Zone::class, 'zone_id');
    }
}
