<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;

class Slide extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $mediaModel = Media::class;
    use HasFactory , InteractsWithMedia ;
    protected $fillable = [
        'name',
        'description',
        'status',
        'url',
    ];
  public function registerMediaCollections(): void
    {
        $this
            ->addMediaCollection('slider_images')
            ->useFallbackUrl(asset('img/ball.png'))
            ->singleFile();  // إذا تريد صورة واحدة فقط لكل Slide
    }
    public function getImageAttribute()
    {
        return $this->getFirstMediaUrl('slider_images') ?: asset('img/ball.png');
    }
}
