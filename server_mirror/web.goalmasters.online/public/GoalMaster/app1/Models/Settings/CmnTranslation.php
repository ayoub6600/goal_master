<?php

namespace App\Models\Settings;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnTranslation extends Model
{
    use HasFactory;
    protected $fillable = [
        'id',
        'cmn_language_id',
        'lang_key',
        'lang_value'
    ];
    
    public function language()
    {
        return $this->belongsTo(CmnLanguage::class);
    }
}
