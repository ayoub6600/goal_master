<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HrmDesignation extends Model
{
    use HasFactory;

    protected $fillable = [
        'id',
        'name',
        'order',
        'created_by',
        'updated_by',
    ];


}
