<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Order\CmnOrder;
use App\Http\Repository\Customer\OrderRepository;
use Illuminate\Http\Request;
use App\Enums\OrderStatus;
use Exception;

class ClientOrderController extends Controller
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
                $rtrData = $order->getCustomerOrder(auth()->id());
                return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
            } catch (Exception $ex) {
                return $this->apiResponse(['status' => '403', 'data' => $ex->getMessage()], 400);
            }
        }else
            return view('site.client.client-order');
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
     * @param  \App\Models\Payment\CmnOrder  $cmnOrder
     * @return \Illuminate\Http\Response
     */
    public function show(CmnOrder $cmnOrder)
    {
        $order_status = new OrderStatus(1);
        return view('site.client.client-order-details',['order' => $cmnOrder, 'order_status' => $order_status->key]);
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Payment\CmnOrder  $cmnOrder
     * @return \Illuminate\Http\Response
     */
    public function edit(CmnOrder $cmnOrder)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Payment\CmnOrder  $cmnOrder
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, CmnOrder $cmnOrder)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Payment\CmnOrder  $cmnOrder
     * @return \Illuminate\Http\Response
     */
    public function destroy(CmnOrder $cmnOrder)
    {
        //
    }
}
