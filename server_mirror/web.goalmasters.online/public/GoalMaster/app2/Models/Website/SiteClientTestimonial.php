<?php

namespace App\Models\Website;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SiteClientTestimonial extends Model
{
    protected $fillable = [
        'id',
        'name',
        'description',
        'rating',
        'image',
        'contact_phone',
        'contact_email',
        'client_ref',
        'status',
        'created_by',
        'updated_by'
    ];
}
