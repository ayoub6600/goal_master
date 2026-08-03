<?php

namespace App\Models\Website;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SitePhotoGallery extends Model
{
    protected $fillable = [
        'id',
        'name',
        'image_url',
        'order',
        'status',
        'description',
        'created_by',
        'updated_by'
    ];
}
