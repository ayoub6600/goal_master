<?php

namespace App\Http\Controllers\Order;

use App\Http\Controllers\Controller;
use App\Models\Order\CmnOrder;
use Illuminate\Http\Request;
use App\Http\Repository\Customer\OrderRepository;
use App\Enums\OrderStatus;
use Exception;

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index(Request $request)
    {
        if($request->wantsJson()){
            try {
                $order = new OrderRepository();
                $rtrData = $order->getCustomerOrderAll();
                return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
            } catch (Exception $ex) {
                return $this->apiResponse(['status' => '403', 'data' => $ex->getMessage()], 400);
            }
        }else
            return view('order.index');
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Payment\CmnOrder  $order
     * @return \Illuminate\Http\Response
     */
    public function show(CmnOrder $order)
    {
        $order_status = new OrderStatus((int)$order->status);
        return view('order.order-details',['order' => $order, 'order_status' => $order_status->key]);
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Payment\CmnOrder  $order
     * @return \Illuminate\Http\Response
     */
    public function edit(CmnOrder $order)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Payment\CmnOrder  $order
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, CmnOrder $order)
    {
        $request->validate([
            'status' => 'required|integer|min:1|max:4'
        ]);
        $order->status = $request->status;
        $order->update();

        
        foreach($order->details as $key => $value){
            if($value->balance){
                $value->balance->status = ($order->status == 3) ? 1 : 0;
                $value->balance->update();
            }
        }

        return $this->apiResponse(['status' => '1', 'data' => 'Updated'], 200);
        
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Payment\CmnOrder  $order
     * @return \Illuminate\Http\Response
     */
    public function destroy(CmnOrder $order)
    {
        //
    }
}
