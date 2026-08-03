<?php

namespace App\Http\Repository\Payment;

use App\Contract\PaymentInterface;
use App\Enums\MessageType;
use App\Enums\PaymentType;
use App\Enums\ServicePaymentStatus;
use App\Enums\ServiceStatus;
use App\Http\Repository\Booking\BookingRepository;
use App\Http\Repository\SmsNotification\SmsNotificationRepository;
use App\Http\Repository\UtilityRepository;
use App\Models\Booking\SchServiceBooking;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Customer\CmnCustomer;
use App\Models\Employee\SchEmployee;
use App\Models\Payment\CmnCurrencySetup;
use App\Models\Payment\CmnPaypalApiConfig;
use App\Models\User;
use App\Notifications\ServiceBookingNotification;
use App\Notifications\ServiceOrderNotification;
use Carbon\Carbon;
use ErrorException;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Session;
use PayPalCheckoutSdk\Core\PayPalHttpClient;
use PayPalCheckoutSdk\Core\ProductionEnvironment;
use PayPalCheckoutSdk\Core\SandboxEnvironment;
use PayPalCheckoutSdk\Orders\OrdersCreateRequest;
use PayPalHttp\HttpException;

class PaypalRepository implements PaymentInterface
{
    public function checkout($amount, $paymentType, $refNo)
    {
        try {
            $paypalConfig = CmnPaypalApiConfig::select('client_id', 'client_secret', 'sandbox')->first();
            if ($paypalConfig == null)
                throw new ErrorException(translate('You do not have paypal configure.'));

            $currency = CmnCurrencySetup::select('value')->first();
            if ($currency != null) {
                $currency = $currency->value;
            } else {
                $currency = "USD";
            }
            
            $clientId = $paypalConfig->client_id;
            $clientSecret = $paypalConfig->client_secret;
            $environment = new SandboxEnvironment($clientId, $clientSecret);
            if ($paypalConfig->sandbox == 0) {
                $environment = new ProductionEnvironment($clientId, $clientSecret);
            }
            $client = new PayPalHttpClient($environment);


            $request = new OrdersCreateRequest();
            $request->prefer('return=representation');
            $request->body = [
                "intent" => "CAPTURE",
                "purchase_units" => [[
                    "reference_id" => $refNo,
                    "amount" => [
                        "value" => round($amount, 2),
                        "currency_code" => $currency
                    ]
                ]],
                "application_context" => [
                    "cancel_url" => url('paypal/payment/cancel'),
                    "return_url" => url('paypal-payment-done')
                ]
            ];


            // Call API with your client and get a response for your call
            $response = $client->execute($request);

            // If call returns body in response, you can get the deserialized version from the result attribute of the response
            if ($response->statusCode == 201) {
                Session::put('paypal_order_info', ['paymentType' => $paymentType, 'refNo' => $refNo]);
                return ['status' => 201, 'data' => $response->result];
            } else {
                //cancel order                
                return ['status' => -101, 'message' => "Failed to generate payment"];
            }
        } catch (HttpException $ex) {
            return ['status' => $ex->statusCode, 'message' => $ex->getMessage()];
        }
    }

    public function updateServicePaymentInfo($response)
    {
        $serviceBoockedInfoId = $response->purchase_units[0]->reference_id;
        $bookedServiceInfo = SchServiceBookingInfo::where('id', $serviceBoockedInfoId)->first();
        $bookedService = SchServiceBooking::where('sch_service_booking_info_id', $serviceBoockedInfoId)->get();

        $totalServiceAmount = $bookedServiceInfo->total_amount;
        foreach ($bookedService as $service) {
            $paidAmount = $service->service_amount * ($response->purchase_units[0]->amount->value / $totalServiceAmount);
            $service->paid_amount = $paidAmount;
            $service->payment_status = ServicePaymentStatus::Paid;
            $service->status = ServiceStatus::Approved;
            $service->update();
        }

        $bookedServiceInfo->payments()->create(
            [
                'payment_type' => PaymentType::Paypal,
                'payment_amount' => $response->purchase_units[0]->amount->value,
                'payment_fee' => $response->purchase_units[0]->payments->captures[0]->seller_receivable_breakdown->paypal_fee->value,
                'currency_code' => $response->purchase_units[0]->amount->currency_code,
                'payee_email_address' => $response->purchase_units[0]->payee->email_address,
                'payee_crd_no' => '',
                'payment_create_time' => $response->create_time,
                'payment_details' => json_encode($response->purchase_units),
                'order_id' => $response->id
            ]
        );

        //email confirm notification
        $customer = CmnCustomer::where('id', $bookedServiceInfo->cmn_customer_id)->select('phone_no', 'email', 'full_name')->first();
        if (UtilityRepository::isEmailConfigured()) {
            $user = '';
            if (auth()->check()) {
                $user = auth()->user();
            } else {
                $user = User::first();
                $user->email = $customer->email;
                $user->phone_no = $customer->phone_no;
                $user->full_name = $customer->full_name;
            }
            $bookingRepo = new BookingRepository();
            Notification::send($user, new ServiceOrderNotification($bookingRepo->getServiceInvoice($serviceBoockedInfoId)));
        }

        //SMS notification       
        SmsNotificationRepository::sendNotification(
            $customer->phone_no,
            MessageType::ServiceConfirm,
            [
                ['key' => '{order_number}', 'value' =>   $serviceBoockedInfoId]
            ]
        );

        return 1;
    }


    public function updateServiceDuePayment($response)
    {
        $serviceBoockedId = $response->purchase_units[0]->reference_id;
        $bookedService = SchServiceBooking::where('id', $serviceBoockedId)->first();

        $bookedService->paid_amount = $response->purchase_units[0]->amount->value;
        $bookedService->payment_status = ServicePaymentStatus::Paid;
        $bookedService->status = ServiceStatus::Approved;
        $bookedService->update();


        $bookedService->payments()->create(
            [
                'payment_type' => PaymentType::Paypal,
                'payment_amount' => $response->purchase_units[0]->amount->value,
                'payment_fee' => $response->purchase_units[0]->payments->captures[0]->seller_receivable_breakdown->paypal_fee->value,
                'currency_code' => $response->purchase_units[0]->amount->currency_code,
                'payee_email_address' => $response->purchase_units[0]->payee->email_address,
                'payee_crd_no' => '',
                'payment_create_time' => $response->create_time,
                'payment_details' => json_encode($response->purchase_units),
                'order_id' => $response->id
            ]
        );

        //email confirm notification
        $serviceDate = new Carbon($bookedService->service_date);
        $customer = CmnCustomer::where('id', $bookedService->cmn_customer_id)->select('phone_no', 'email', 'full_name')->first();
        if (UtilityRepository::isEmailConfigured()) {
            $user = '';
            if (auth()->check()) {
                $user = auth()->user();
            } else {
                $user = User::first();
                $user->email = $customer->email;
                $user->phone_no = $customer->phone_no;
                $user->full_name = $customer->full_name;
            }

            $serviceMessage = [
                'user_name' => $user->name,
                'message_subject' => 'Booking confirm notification',
                'message_body' => 'Your booking is confirm',
                'booking_info' => ' Booking No#' .  $bookedService->id . ', Service Date# ' . $serviceDate->format('D, M d, Y') . ' at ' . $bookedService->start_time . ' to ' .  $bookedService->end_time,
                'message_footer' => 'Thanks you for choosing our service.',
                'action_url' => url('/client-dashboard')
            ];
            Notification::send($user, new ServiceBookingNotification($serviceMessage));
        }

        //SMS notification       
        SmsNotificationRepository::sendNotification(
            $customer->phone_no,
            MessageType::ServiceConfirm,
            [
                ['key' => '{booking_number}', 'value' =>    $bookedService->id],
                ['key' => '{service_status}', 'value' =>    "Confirm"],
                ['key' => '{service_date}', 'value' =>   $serviceDate->format('D, M d, Y')],
                ['key' => '{service_start}', 'value' =>    $bookedService->start_time],
                ['key' => '{service_end}', 'value' =>    $bookedService->end_time]
            ]
        );

        return 1;
    }
}
