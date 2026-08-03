<?php

namespace App\Http\Controllers\Payment;

use App\Enums\PaymentFor;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Site\SiteController;
use App\Http\Repository\Payment\PaymentGatewayRepository;
use App\Http\Repository\Payment\UserBalanceRepository;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class UserBalanceController extends Controller
{
    public function done()
    {
        try {
            if (Session::get("user_balance_order_info")['paymentType'] == PaymentFor::ServiceCharge) {
                $paymentGateway = new PaymentGatewayRepository(new UserBalanceRepository());
                $paymentGateway->updateServicePaymentInfo("nothing");
                Session::forget("user_balance_order_info");
                return redirect()->route('payment.complete');
            } else if(Session::get("user_balance_order_info")['paymentType'] ==PaymentFor::ServiceDuePayment){
                $paymentGateway = new PaymentGatewayRepository(new UserBalanceRepository());
                $paymentGateway->updateServiceDuePayment("nothing");
                Session::forget("user_balance_order_info");
                return redirect()->route('payment.complete');
            } else if(Session::get("user_balance_order_info")['paymentType'] ==PaymentFor::OrderPayment){
                //product/voucher order insert
                return redirect()->route('site.order.store');
            }else {
                return redirect()->route('cancel.userbalance.payment');
            }
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            return ['status' => $ex->statusCode, 'message' => $ex->getMessage()];
        }
    }


    public function cancel()
    {
        if (Session::has("user_balance_order_info")) {
            if (Session::get("user_balance_order_info")['paymentType'] == PaymentFor::ServiceCharge) {
                $refNo = Session::get("user_balance_order_info")['refNo'];
                $siteCon = new SiteController();
                $siteCon->cancelServiceOrder($refNo);
                Session::forget("user_balance_order_info");
            }else if(Session::get("user_balance_order_info")['paymentType'] == PaymentFor::ServiceDuePayment){
                $refNo = Session::get("user_balance_order_info")['refNo'];
                $siteCon = new SiteController();
                $siteCon->cancelService($refNo);
                Session::forget("user_balance_order_info");
            }else if(Session::get("user_balance_order_info")['paymentType'] ==PaymentFor::OrderPayment){
                //nothing
            }
        }
        return redirect()->route('unsuccessful.payment');
    }
}
