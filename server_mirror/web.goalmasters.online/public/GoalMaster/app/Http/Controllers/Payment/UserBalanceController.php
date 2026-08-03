<?php

namespace App\Http\Controllers\Payment;

use App\Enums\PaymentFor;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Site\SiteController;
use App\Http\Repository\Payment\PaymentGatewayRepository;
use App\Http\Repository\Payment\UserBalanceRepository;
use App\Models\User;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use App\Services\WhatsAppService;

class UserBalanceController extends Controller
{
    public function done()
    {
        $whatsAppService = new WhatsAppService;
        try {
            if (Session::get("user_balance_order_info")['paymentType'] == PaymentFor::ServiceCharge) {
                $paymentGateway = new PaymentGatewayRepository(new UserBalanceRepository($whatsAppService));
                $paymentGateway->updateServicePaymentInfo("nothing");
                Session::forget("user_balance_order_info");
                return redirect()->route('payment.complete');
            } else if(Session::get("user_balance_order_info")['paymentType'] ==PaymentFor::ServiceDuePayment){
                $paymentGateway = new PaymentGatewayRepository(new UserBalanceRepository($whatsAppService));
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
        $whatsAppService = new WhatsAppService;
        if (Session::has("user_balance_order_info")) {
            if (Session::get("user_balance_order_info")['paymentType'] == PaymentFor::ServiceCharge) {
                $refNo = Session::get("user_balance_order_info")['refNo'];
                $siteCon = new SiteController($whatsAppService);
                $siteCon->cancelServiceOrder($refNo);
                Session::forget("user_balance_order_info");
            }else if(Session::get("user_balance_order_info")['paymentType'] == PaymentFor::ServiceDuePayment){
                $refNo = Session::get("user_balance_order_info")['refNo'];
                $siteCon = new SiteController($whatsAppService);
                $siteCon->cancelService($refNo);
                Session::forget("user_balance_order_info");
            }else if(Session::get("user_balance_order_info")['paymentType'] ==PaymentFor::OrderPayment){
                //nothing
            }
        }
        return redirect()->route('unsuccessful.payment');
    }



    public function add(Request $request)
    {

        $request->validate([
            'user_id' => 'required|integer',
            'balance' => 'required|numeric',
        ]);

        try {

            $userId = $request->input('user_id');
            $amount = $request->input('balance');
          
            $user = User::where('id', $userId)->first();
            $rtr = $user->userBalance()->create([
                // 'balanceable_type' => PaymentType::UserBalance,
                'amount' => $amount,
                'user_id' => $userId,
                'balance_type' => 1,
                'status' => 1
            ]);
            return response()->json(['message' => 'Balance added successfully!']);
        }catch (Exception $ex) {
            return response()->json(['error' => $ex]);
        }

    }

}
