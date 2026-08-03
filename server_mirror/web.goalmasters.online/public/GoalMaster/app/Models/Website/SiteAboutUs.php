<?php

namespace App\Models\Website;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SiteAboutUs extends Model
{
    protected $fillable = [
        'id',
        'title',
        'details',
        'image_url',
        'order',
        'status',
        'created_by',
        'updated_by'
    ];
}
