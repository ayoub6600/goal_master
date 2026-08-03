<?php

namespace App\Http\Repository\Coupon;

use App\Http\Repository\UtilityRepository;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Customer\CmnCustomer;
use App\Models\Settings\CmnCoupon;
use Carbon\Carbon;
use ErrorException;


class CouponRepository
{

    public function validateAndGetCouponValue($userId, $couponCode, $orderAmount)
    {
        if (UtilityRepository::emptyOrNullToZero($couponCode) == 0)
            return 0;
        $today = Carbon::now();
        $today = $today->toDateTimeString();
        $customer = CmnCustomer::where('user_id', $userId)->select('id')->first();
        if ($customer == null)
            throw new ErrorException(translate("You need to signup as customer to before apply this coupon"));
        $coupon = CmnCoupon::where('code', $couponCode)->where('start_date', '<=', $today)
            ->where('end_date', '>=', $today)->where('status', 1)
            ->select('percent', 'use_limit', 'user_id', 'coupon_type', 'min_order_value', 'max_discount_value')->first();
        if ($coupon == null)
            throw new ErrorException(translate("Invalid coupon code"));

        if ($coupon->min_order_value > $orderAmount)
            throw new ErrorException(translate("Minimum order value should be " . $coupon->min_order_value));

        //1 for all user
        if ($coupon->coupon_type == 1) {
            $useCount = SchServiceBookingInfo::where('coupon_code', $couponCode)->count();

            if ($useCount < $coupon->use_limit) {
                $calculatedDiscount = ($orderAmount * $coupon->percent) / 100;
                if ($calculatedDiscount > $coupon->max_discount_value)
                    return $coupon->max_discount_value;
                return $calculatedDiscount;
            }
            throw new ErrorException(translate("Coupon use limit exceeded"));
        } else {
            //2 for spesefic users
            $useCount = SchServiceBookingInfo::where('coupon_code', $couponCode)->where('cmn_customer_id', $customer->id)->count();
            if ($useCount < $coupon->use_limit) {
                $calculatedDiscount = ($orderAmount * $coupon->percent) / 100;
                if ($calculatedDiscount > $coupon->max_discount_value)
                    return $coupon->max_discount_value;
                return $calculatedDiscount;
            }
            throw new ErrorException(translate("Coupon use limit exceeded"));
        }
    }
}
