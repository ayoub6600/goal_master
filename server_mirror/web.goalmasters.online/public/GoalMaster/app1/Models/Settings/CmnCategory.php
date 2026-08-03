<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnCategory extends Model
{
    use HasFactory;

    public $fillable = [
        'name',
        'slug',
        'icon',
        'meta_title',
        'meta_image',
        'meta_content',
        'cmn_category_id',
        'status',
        'created_by',
        'updated_by',
    ];

    public function product(){
        return $this->hasMany('App\Models\Settings\CmnProduct');
    }
}
