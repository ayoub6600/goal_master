<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Settings\CmnProduct;
use Illuminate\Http\Request;

use App\Enums\ProductType;

class VoucherController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('site.voucher-list', ['vouchers' => CmnProduct::where('cmn_type_id', ProductType::Voucher)->where('status', 1)
            ->selectRaw(
                'id,
                thumbnail,
                name,
                description,
                price-((price*discount)/100) as price,
                discount'                
            )->paginate(9)]);
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
     * @param  \App\Models\Settings\CmnProduct  $cmnProduct
     * @return \Illuminate\Http\Response
     */
    public function show(CmnProduct $cmnProduct)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Settings\CmnProduct  $cmnProduct
     * @return \Illuminate\Http\Response
     */
    public function edit(CmnProduct $cmnProduct)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Settings\CmnProduct  $cmnProduct
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, CmnProduct $cmnProduct)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Settings\CmnProduct  $cmnProduct
     * @return \Illuminate\Http\Response
     */
    public function destroy(CmnProduct $cmnProduct)
    {
        //
    }
}
