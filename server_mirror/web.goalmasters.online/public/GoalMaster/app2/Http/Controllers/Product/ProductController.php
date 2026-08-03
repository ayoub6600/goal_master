<?php

namespace App\Http\Controllers\Product;

use App\Http\Controllers\Controller;
use App\Models\Settings\CmnProduct;
use Illuminate\Http\Request;
use App\Http\Repository\Settings\ProductRepository;
use Exception;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index(Request $request)
    {
        if ($request->wantsJson()) {
            try {
                $order = new ProductRepository();
                $rtrData = $order->getAll();
                return $this->apiResponse(['status' => '1', 'data' => $rtrData], 200);
            } catch (Exception $ex) {
                return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
            }
        } else
            return view('product.index');
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
        $validate = Validator::make($request->all(), [
            'name' => 'required|string|max:192',
            'cmn_type_id' => 'required|integer|in:1,2',
            'thumbnail' => 'required|mimes:jpeg,png,jpg|max:1024',
            'status' => 'required|integer|in:0,1',
            'price' => 'required|numeric',
            'quantity' => 'required|integer|min:1'
        ]);

        try {
            if (!$validate->fails()) {
                $product = new CmnProduct();
                $product->name = $request->input('name');
                $product->cmn_type_id = $request->input('cmn_type_id');
                $product->status = $request->input('status');
                $product->price = $request->input('price');
                $product->discount = $request->input('discount');
                $product->quantity = $request->input('quantity');
                $product->images = '[]';
                $product->cmn_category_id = 1;
                $product->unit = 'pcs';

                $tempName = imageName($request->thumbnail->getClientOriginalName(), 1, 'thumbnail');
                $product->thumbnail = $request->thumbnail->storeAs('uploadfiles/products', $tempName);

                $product->save();

                return $this->apiResponse(['status' => '1', 'data' => $product], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validate->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
        }
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Settings\CmnProduct  $product
     * @return \Illuminate\Http\Response
     */
    public function show(CmnProduct $product)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Settings\CmnProduct  $product
     * @return \Illuminate\Http\Response
     */
    public function edit(CmnProduct $product)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Settings\CmnProduct  $product
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, CmnProduct $product)
    {
        $validate = Validator::make($request->all(), [
            'name' => 'required|string|max:192',
            'cmn_type_id' => 'required|integer|in:1,2',
            'status' => 'required|integer|in:0,1',
            'price' => 'required|numeric',
            'quantity' => 'required|integer|min:1'
        ]);

        try {
            if (!$validate->fails()) {
                $product->name = $request->input('name');
                $product->cmn_type_id = $request->input('cmn_type_id');
                $product->status = $request->input('status');
                $product->price = $request->input('price');
                $product->discount = $request->input('discount');
                $product->quantity = $request->input('quantity');
                $product->images = '[]';
                $product->cmn_category_id = 1;
                $product->unit = 'pcs';

                if ($request->hasFile('thumbnail')) {
                    $tempName = imageName($request->thumbnail->getClientOriginalName(), 1, 'thumbnail');
                    $product->thumbnail = $request->thumbnail->storeAs('uploadfiles/products', $tempName);
                }

                $product->update();
                return $this->apiResponse(['status' => '1', 'data' => $product], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validate->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
        }
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Settings\CmnProduct  $product
     * @return \Illuminate\Http\Response
     */
    public function destroy(CmnProduct $product)
    {
        try {
            $product->delete();
            return $this->apiResponse(['status' => '1', 'data' => 'Deleted'], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex->getMessage()], 400);
        }
    }
}
