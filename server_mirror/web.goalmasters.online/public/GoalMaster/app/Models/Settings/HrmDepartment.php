<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HrmDepartment extends Model
{
    protected $fillable = [
        'id',
        'name',
        'order',
        'created_by',
        'updated_by',
    ];
}
