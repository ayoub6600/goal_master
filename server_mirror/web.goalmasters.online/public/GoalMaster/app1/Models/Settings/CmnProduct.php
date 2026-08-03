<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnProduct extends Model
{
    use HasFactory;

    public $fillable = [
        'name',
        'cmn_type_id',
        'cmn_category_id',
        'price',
        'thumbnail',
        'images',
        'description',
        'unit',
        'discount',
        'discount_type',
        'quantity',
        'is_featured',
        'is_hotdeal',
        'is_new',
        'meta_title',
        'meta_image',
        'meta_content',
        'status',
        'created_by',
        'updated_by',
    ];

    public function type(){
        return $this->belongsTo('App\Models\Settings\CmnType', 'cmn_type_id');
    }

    public function category(){
        return $this->belongsTo('App\Models\Settings\CmnCategory');
    }
}
