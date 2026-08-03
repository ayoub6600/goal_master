<?php
namespace App\Models\CardSystem;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Card extends Model
{
    use HasFactory;

    protected $fillable = ['group_id', 'code', 'is_charged'];

    public function group()
    {
        return $this->belongsTo(CardGroup::class, 'group_id');
    }
}
