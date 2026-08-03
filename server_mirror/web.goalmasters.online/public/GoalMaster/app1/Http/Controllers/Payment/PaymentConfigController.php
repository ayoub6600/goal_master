<?php

namespace App\Http\Controllers\Payment;

use App\Enums\PaymentType;
use App\Http\Controllers\Controller;
use App\Models\Payment\CmnCurrencySetup;
use App\Models\Payment\CmnPaymentType;
use App\Models\Payment\CmnPaypalApiConfig;
use App\Models\Payment\CmnStripeApiConfig;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class PaymentConfigController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function paymentConfig()
    {
        return view('payment.payment-config', [
            'paypalConfig' => $this->getPaypalConfig(),
            'paymentConfig' => $this->getPaymentConfig(),
            'stripeConfig' => $this->getStripeConfig(),
            ]);
    }

    public function getPaymentConfig()
    {
        try {
            $data = CmnPaymentType::select(
                'status',
                'type'
            )->get();

            return [
                'local_payment_status' => collect($data)->where('type', PaymentType::LocalPayment)->first()->status,
                'paypal_payment_status' => collect($data)->where('type', PaymentType::Paypal)->first()->status,
                'stripe_payment_status' => collect($data)->where('type', PaymentType::Stripe)->first()->status,
                'currency'=>CmnCurrencySetup::select('value')->first()->value
            ];
        } catch (Exception $ex) {
            return $ex;
        }
    }

    public function getPaypalConfig()
    {
        try {
            $data = CmnPaypalApiConfig::where('cmn_payment_type_id', 2)->select(
                'id',
                'cmn_payment_type_id',
                'client_id',
                'client_secret',
                'sandbox',
                'charge_type',
                'charge_percentage'
            )->first();
            return $data;
        } catch (Exception $ex) {
            return $ex;
        }
    }

    public function getStripeConfig()
    {
        try {
            $data = CmnStripeApiConfig::where('cmn_payment_type_id', 3)->select(
                'id',
                'cmn_payment_type_id',
                'api_key',
                'api_secret',
                'charge_type',
                'charge_percentage'
            )->first();
            return $data;
        } catch (Exception $ex) {
            return $ex;
        }
    }

    public function saveOrUpdateCurrency(Request $request)
    {
        try {
            $validator = Validator::make($request->toArray(), [
                'currency' => ['required'],
                'name' => ['required'],

            ]);

            if (!$validator->fails()) {
                $data = [
                    'value' => $request->currency,
                    'name' => $request->name
                ];
                $savedData = CmnCurrencySetup::first();
                if ($savedData != null) {
                    $savedData->update($data);
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                } else {
                    CmnCurrencySetup::create($data);
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function enableDisableLocalPayment(Request $request)
    {
        try {
            $savedData = CmnPaymentType::where('type', PaymentType::LocalPayment)->first();
            if ($savedData != null) {
                $savedData->status = $request->enableLocalPayment ?? 0;
                $savedData->update();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function enableDisablePaypalPayment(Request $request)
    {
        try {
            $savedData = CmnPaymentType::where('type', PaymentType::Paypal)->first();
            if ($savedData != null) {
                $savedData->status = $request->enablePaypalPayment ?? 0;
                $savedData->update();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function saveOrUpdatePaypalConfig(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'client_id' => ['required', 'string'],
                'client_secret' => ['required']
            ]);
            if (!$validator->fails()) {
                $request['sandbox'] = $request->sandbox ?? 0;
               $paymentTypeId=CmnPaymentType::where('type',PaymentType::Paypal)->select('id')->first()->id;
                $request['cmn_payment_type_id'] = $paymentTypeId;
                $savedData = CmnPaypalApiConfig::where('cmn_payment_type_id', $paymentTypeId)->first();
                if ($savedData != null) {
                    $request['cmn_payment_type_id'] = $paymentTypeId;
                    $savedData->update($request->all());
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                } else {
                    CmnPaypalApiConfig::create($request->all());
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                }
            }
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    //stripe
    public function enableDisableStripePayment(Request $request)
    {
        try {
            $savedData = CmnPaymentType::where('type', PaymentType::Stripe)->first();
            
            if ($savedData != null) {
                $savedData->status = ($request->enableStripePayment=='true'? 1:0);
                $savedData->update();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function saveOrUpdateStripeConfig(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'api_key' => ['required', 'string'],
                'api_secret' => ['required']
            ]);
            if (!$validator->fails()) {
                $paymentTypeId= CmnPaymentType::where('type',PaymentType::Stripe)->select('id')->first()->id;
                $request['cmn_payment_type_id'] =$paymentTypeId;
                $savedData = CmnStripeApiConfig::where('cmn_payment_type_id', $paymentTypeId)->first();
                if ($savedData != null) {
                    $request['cmn_payment_type_id'] = $paymentTypeId;;
                    $savedData->update($request->all());
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                } else {
                    CmnStripeApiConfig::create($request->all());
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                }
            }
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
}
