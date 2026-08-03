<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnType extends Model
{
    use HasFactory;

    public $fillable = [
        'name',
        'slug',
        'status',
        'created_by',
        'updated_by',
    ];

    public function product(){
        return $this->hasMany('App\Models\Settings\CmnProduct');
    }
}
