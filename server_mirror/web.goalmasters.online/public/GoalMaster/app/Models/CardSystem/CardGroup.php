<?php

namespace App\Models\CardSystem;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CardGroup extends Model
{
    use HasFactory;

    protected $fillable = ['price', 'formula', 'count'];

    public function cards()
    {
        return $this->hasMany(Card::class, 'group_id');
    }
}
