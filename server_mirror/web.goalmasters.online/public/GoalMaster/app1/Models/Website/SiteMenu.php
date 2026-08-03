<?php

namespace App\Models\Website;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SiteMenu extends Model
{
    protected $fillable = [
        'id',
        'name',
        'site_menu_id',
        'route',
        'remarks',
        'order',
        'status',
        'created_by',
        'updated_by'
    ];

  
}
