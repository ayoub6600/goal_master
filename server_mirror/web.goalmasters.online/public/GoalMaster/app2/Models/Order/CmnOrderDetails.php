<?php

namespace App\Models\Order;

use App\Models\Customer\CmnUserBalance;
use App\Models\Settings\CmnProduct;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnOrderDetails extends Model
{
    use HasFactory;

    public $timestamps = false;

    public $fillable = [
        'cmn_order_id',
        'cmn_product_id',
        'product_price',
        'product_quantity',
        'total_price',
        'discount_amount',
        'shipping_amount',
        'paid_amount',
    ];

    public function order(){
        return $this->belongsTo(CmnOrder::class,'cmn_order_id');
    }

    public function product(){
        return $this->belongsTo(CmnProduct::class,'cmn_product_id');
    }

    public function balance(){
        return $this->morphOne(CmnUserBalance::class,'balanceable');
    }
}
