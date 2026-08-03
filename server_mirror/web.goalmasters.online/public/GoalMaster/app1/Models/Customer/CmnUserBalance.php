<?php

namespace App\Models\Customer;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnUserBalance extends Model
{
    use HasFactory;

    public $fillable = [
        'balanceable_id',
        'balanceable_type',
        'amount',
        'user_id',
        'balance_type',
        'status'
    ];

    public function balanceable(){
        return $this->morphTo();
    }
}
