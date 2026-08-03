<?php

namespace App\Http\Controllers\Payment;

use App\Contract\PaymentInterface;
use App\Enums\MessageType;
use App\Enums\PaymentFor;
use App\Enums\PaymentType;
use App\Enums\ServicePaymentStatus;
use App\Enums\ServiceStatus;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Site\SiteController;
use App\Http\Repository\Payment\PaymentGatewayRepository;
use App\Http\Repository\Payment\PaypalRepository;
use App\Http\Repository\SmsNotification\SmsNotificationRepository;
use App\Http\Repository\UtilityRepository;
use App\Models\Booking\SchServiceBooking;
use App\Models\Employee\SchEmployee;
use Illuminate\Http\Request;
use App\Models\Payment\CmnPaypalApiConfig;
use App\Models\User;
use App\Notifications\ServiceBookingNotification;
use Carbon\Carbon;
use ErrorException;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Session;
use PayPalCheckoutSdk\Core\PayPalHttpClient;
use PayPalCheckoutSdk\Core\ProductionEnvironment;
use PayPalCheckoutSdk\Core\SandboxEnvironment;
use PayPalCheckoutSdk\Orders\OrdersCaptureRequest;
use PayPalCheckoutSdk\Orders\OrdersCreateRequest;
use PayPalHttp\HttpException;



class PaypalController extends Controller
{

    public function done(Request $responseData)
    {
        try {
            $paypalConfig = CmnPaypalApiConfig::select('client_id', 'client_secret', 'sandbox')->first();
            $clientId = $paypalConfig->client_id;
            $clientSecret = $paypalConfig->client_secret;
            $environment = new SandboxEnvironment($clientId, $clientSecret);
            if ($paypalConfig->sandbox == 0) {
                $environment = new ProductionEnvironment($clientId, $clientSecret);
            }

            $client = new PayPalHttpClient($environment);
            $request = new OrdersCaptureRequest($responseData->token);
            $request->prefer('return=representation');

            // Call API with your client and get a response for your call
            $response = $client->execute($request);
            // If call returns body in response, you can get the deserialized version from the result attribute of the response
            if ($response->statusCode == 201) {
                if (Session::get("paypal_order_info")['paymentType'] ==PaymentFor::ServiceCharge) {
                    $paypal = new PaypalRepository();
                    $paymentGateway = new PaymentGatewayRepository($paypal);
                    $paymentGateway->updateServicePaymentInfo($response->result);
                    Session::forget("paypal_order_info");
                    return redirect()->route('payment.complete');
                }else if(Session::get("paypal_order_info")['paymentType'] ==PaymentFor::ServiceDuePayment){
                    $paypal = new PaypalRepository();
                    $paymentGateway = new PaymentGatewayRepository($paypal);
                    $paymentGateway->updateServiceDuePayment($response->result);
                    Session::forget("paypal_order_info");
                    return redirect()->route('payment.complete');
                }else if(Session::get("paypal_order_info")['paymentType'] ==PaymentFor::OrderPayment){
                    //product/voucher order insert
                    return redirect()->route('site.order.store');
                } else {
                    return redirect()->route('cancel.paypal.payment');
                }
            }
            return redirect()->route('cancel.paypal.payment');
        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (HttpException $ex) {
            return ['status' => $ex->statusCode, 'message' => $ex->getMessage()];
        }
    }

    public function cancel()
    {
        if (Session::has("paypal_order_info")) {
            if (Session::get("paypal_order_info")['paymentType'] == PaymentFor::ServiceCharge) {
                $refNo = Session::get("paypal_order_info")['refNo'];
                $siteCon = new SiteController();
                $siteCon->cancelServiceOrder($refNo);
                Session::forget("paypal_order_info");
            }else if(Session::get("paypal_order_info")['paymentType'] == PaymentFor::ServiceDuePayment){
                $refNo = Session::get("paypal_order_info")['refNo'];
                $siteCon = new SiteController();
                $siteCon->cancelService($refNo);
                Session::forget("paypal_order_info");
            }else if(Session::get("paypal_order_info")['paymentType'] == PaymentFor::OrderPayment){
                //nothing
            }
        }
        return redirect()->route('unsuccessful.payment');
    }
}
