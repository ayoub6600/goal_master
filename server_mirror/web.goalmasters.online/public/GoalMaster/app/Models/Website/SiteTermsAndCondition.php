<?php

namespace App\Models\Website;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SiteTermsAndCondition extends Model
{
    protected $fillable = [
        'id',
        'details',        
        'status',
        'created_by',
        'updated_by'
    ];
}
