<?php

namespace App\Models\Customer;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class CmnUserBalance extends Model
{
    use HasFactory;

    public $fillable = [
        'balanceable_id',
        'balanceable_type',
        'amount',
        'user_id',
        'reference_user_id',
        'balance_type',
        'status',
        'type'
    ];

    public function balanceable()
    {
        return $this->morphTo();
    }
  
    public function referenceUser()
    {
        return $this->belongsTo(User::class, 'reference_user_id')
            ->select('id', 'name', 'username', 'phone_number');
    }



    public function user()
    {
        return $this->belongsTo(User::class)
            ->select('id', 'name', 'username', 'phone_number');
    }

}
