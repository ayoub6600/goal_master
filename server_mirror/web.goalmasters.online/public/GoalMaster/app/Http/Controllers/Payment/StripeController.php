<?php

namespace App\Http\Controllers\Payment;

use App\Enums\MessageType;
use App\Enums\PaymentFor;
use App\Enums\PaymentType;
use App\Enums\ServicePaymentStatus;
use App\Enums\ServiceStatus;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Site\SiteController;
use App\Http\Repository\Payment\PaymentGatewayRepository;
use App\Http\Repository\Payment\StripeRepository;
use App\Http\Repository\SmsNotification\SmsNotificationRepository;
use App\Http\Repository\UtilityRepository;
use App\Models\Booking\SchServiceBooking;
use App\Models\Employee\SchEmployee;
use App\Models\Payment\CmnStripeApiConfig;
use Carbon\Carbon;
use Illuminate\Support\Facades\Notification;
use App\Models\User;
use App\Notifications\ServiceBookingNotification;
use ErrorException;
use Illuminate\Support\Facades\Session;
use PayPalHttp\HttpException;

class StripeController extends Controller
{

    public function done()
    {
        try {
            if (Session::get("stripe_order_info")['paymentType'] == PaymentFor::ServiceCharge) {

                $stripe = new StripeRepository();
                $paymentGateway = new PaymentGatewayRepository($stripe);
                $paymentGateway->updateServicePaymentInfo("nothing");
                Session::forget("stripe_order_info");
                return redirect()->route('payment.complete');
            }else if(Session::get("stripe_order_info")['paymentType'] ==PaymentFor::ServiceDuePayment){
                $stripe = new StripeRepository();
                $paymentGateway = new PaymentGatewayRepository($stripe);
                $paymentGateway->updateServiceDuePayment("nothing");
                Session::forget("stripe_order_info");
                return redirect()->route('payment.complete');
            }else if(Session::get("stripe_order_info")['paymentType'] ==PaymentFor::OrderPayment){
                //product/voucher order insert
                return redirect()->route('site.order.store');
            } else {
                return redirect()->route('stripe.payment.cancel');
            }
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (HttpException $ex) {
            return ['status' => $ex->statusCode, 'message' => $ex->getMessage()];
        }
    }


    public function cancel()
    {
        if (Session::has("stripe_order_info")) {
            if (Session::get("stripe_order_info")['paymentType'] == PaymentFor::ServiceCharge) {
                $refNo = Session::get("stripe_order_info")['refNo'];
                $siteCon = new SiteController();
                $siteCon->cancelServiceOrder($refNo);
                Session::forget("stripe_order_info");
            }else if(Session::get("stripe_order_info")['paymentType'] == PaymentFor::ServiceDuePayment){
                $refNo = Session::get("stripe_order_info")['refNo'];
                $siteCon = new SiteController();
                $siteCon->cancelService($refNo);
                Session::forget("stripe_order_info");
            }else if(Session::get("stripe_order_info")['paymentType'] ==PaymentFor::OrderPayment){
                //nothing
            }
        }
        return redirect()->route('unsuccessful.payment');
    }
}
