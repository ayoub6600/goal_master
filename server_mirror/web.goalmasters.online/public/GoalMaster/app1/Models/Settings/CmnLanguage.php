<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnLanguage extends Model
{
    use HasFactory;
    protected $fillable = [
        'id',
        'name',
        'code',
        'rtl',
        'default_language'
    ];
}
