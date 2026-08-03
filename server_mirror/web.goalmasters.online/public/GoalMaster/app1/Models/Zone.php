<?php

namespace App\Models;

use App\Models\Settings\CmnBranch;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Zone extends Model
{
    use HasFactory;
    
    protected $table = 'zones';
    protected $fillable = [
    	'id',
		'name'
	];
 
    public function branches(): HasMany
	{
		return $this->hasMany(CmnBranch::class,'zone_id');
	}
}
