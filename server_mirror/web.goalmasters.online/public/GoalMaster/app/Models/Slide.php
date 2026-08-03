<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Slide extends Model implements    HasMedia
{
    use HasFactory , InteractsWithMedia ;
    protected $fillable = [
        'name',
        'description',
        'status',
        'url',
    ];

    public function getImageAttribute()
    {
        return $this->getFirstMediaUrl('slider_images') ?: asset('img/ball.png');
    }


}
