<?php

namespace App\Models\Website;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SiteFrequentlyAskedQuestion extends Model
{
    protected $fillable = [
        'id',
        'question',
        'answer',
        'order',
        'status',
        'created_by',
        'updated_by'
    ];
}
