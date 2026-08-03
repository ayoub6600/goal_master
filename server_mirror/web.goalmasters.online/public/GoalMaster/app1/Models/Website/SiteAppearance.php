<?php

namespace App\Models\Website;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SiteAppearance extends Model
{
    protected $fillable = [
        'id',
        'app_name',
        'logo',
        'icon',
        'motto',
        'theam_color',
        'theam_menu_color2',
        'theam_hover_color',
        'theam_active_color',
        'facebook_link',
        'youtube_link',
        'twitter_link',
        'instagram_link',
        'about_service',
        'contact_email',
        'contact_phone',
        'contact_web',
        'address',
        'background_image',
        'login_background_image',
        'meta_title',
        'meta_description',
        'meta_keywords',
        'created_by',
        'updated_by'
    ];
}
