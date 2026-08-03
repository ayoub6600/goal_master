<?php

namespace App\Models\Order;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnOrder extends Model
{
    use HasFactory;

    public $fillable = [
        'code',
        'user_id',
        'amount',
        'discount_amount',
        'shipping_amount',
        'shipping_details',
        'cmn_coupon_id',
        'coupon_amount',
        'payment_status',
        'shipping_status',
        'status',
        'updated_by',
    ];

    public $casts = [
        'shipping_details' => 'object'
    ];

    public function details(){
        return $this->hasMany(CmnOrderDetails::class);
    }

    public function user(){
        return $this->belongsTo(User::class);
    }
}
