<?php

namespace App\Models\Website;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SiteGoogleMap extends Model
{
    protected $fillable = [
        'id',
        'lat',
        'long',
        'map_key',
        'created_by',
        'updated_by'
    ];
}
