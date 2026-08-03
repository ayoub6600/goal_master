<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;

use App\Models\Settings\CmnCoupon;
use App\Models\Customer\CmnCustomer;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CouponController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('settings.coupon',['customers' =>  CmnCustomer::get()]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'code' => ['required', 'string', 'max:300','unique:cmn_coupons'],
                'start_date' => ['required', 'date', 'after_or_equal:'.date('Y-m-d')],
                'end_date' => ['required', 'date', 'after_or_equal:'.date('Y-m-d'), 'after_or_equal:start_date'],
                'percent' => ['required', 'numeric'],
                'coupon_type' => ['required', 'integer', 'in:1,2'],
                'customer_id' => ['required_if:coupon_type,2', 'integer', 'exists:cmn_customers,id'],
                'use_limit' => ['required', 'integer', 'min:1'],
                'status' => ['required', 'integer','in:1,0']
            ]);

            if (!$validator->fails()) {
                $data = $request->all();
                $data['created_by'] = auth()->id();
                $data['user_id'] = ($data['customer_id'])?$data['customer_id']:null;
                unset($data['customer_id']);
                CmnCoupon::create($data);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\CmnCoupon  $cmnCoupon
     * @return \Illuminate\Http\Response
     */
    public function show(CmnCoupon $cmnCoupon)
    {
        try {
            return $this->apiResponse(['status' => '1', 'data' => $cmnCoupon], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\CmnCoupon  $cmnCoupon
     * @return \Illuminate\Http\Response
     */
    public function edit(CmnCoupon $cmnCoupon)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\CmnCoupon  $cmnCoupon
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, CmnCoupon $cmnCoupon)
    {
        try {
            $validator = Validator::make($request->all(), [
                'code' => ['required', 'string', 'max:300','unique:cmn_coupons,id,'.$cmnCoupon->id],
                'start_date' => ['required', 'date'],
                'end_date' => ['required', 'date', 'after_or_equal:start_date'],
                'percent' => ['required', 'numeric'],
                'coupon_type' => ['required', 'integer', 'in:1,2'],
                'customer_id' => ['required_if:coupon_type,2', 'integer', 'exists:cmn_customers,id'],
                'use_limit' => ['required', 'integer', 'min:1'],
                'status' => ['required', 'integer','in:1,0']
            ]);

            if (!$validator->fails()) {
                $data = $request->all();
                $data['user_id'] = ($data['customer_id'])?$data['customer_id']:null;
                unset($data['customer_id']);
                $data['updated_by'] = auth()->id();
                $cmnCoupon->update($data);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\CmnCoupon  $cmnCoupon
     * @return \Illuminate\Http\Response
     */
    public function destroy(CmnCoupon $cmnCoupon)
    {
        try {
            $rtr = $cmnCoupon->delete();
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function getCouponList()
    {
        try {
            $data = CmnCoupon::with('customer')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
