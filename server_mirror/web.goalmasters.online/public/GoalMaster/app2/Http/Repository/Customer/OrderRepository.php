<?php
namespace App\Http\Repository\Customer;

use App\Models\Order\CmnOrder;

class OrderRepository{

    public function getCustomerOrder($userId){
        return CmnOrder::select('id','code','amount','status','created_at','payment_status')->where('user_id',$userId)->get();
    }

    public function getCustomerOrderAll(){
        return CmnOrder::select('id','code','user_id','amount','status','created_at','payment_status')->with('user:id,name')->get();   
    }
}