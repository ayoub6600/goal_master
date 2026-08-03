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
use App\Models\Payment\CmnStripeApiConfig;
use App\Models\User;
use App\Notifications\ServiceBookingNotification;
use App\Notifications\ServiceOrderNotification;
use Carbon\Carbon;
use ErrorException;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Session;
use PayPalHttp\HttpException;

class StripeRepository implements PaymentInterface
{
    public function checkout($amount, $paymentType, $refNo)
    {
        try {

            $stripeConfig = CmnStripeApiConfig::select('api_key', 'api_secret')->first();
            if ($stripeConfig == null)
                throw new ErrorException(translate('You do not have stripe configure.'));

            $currency = CmnCurrencySetup::select('value')->first();
            if ($currency != null) {
                $currency = $currency->value;
            } else {
                $currency = "USD";
            }


            $apiKey = $stripeConfig->api_key;
            $apiSecret = $stripeConfig->api_secret;


            \Stripe\Stripe::setApiKey($apiSecret);
            $session = \Stripe\Checkout\Session::create([
                'payment_method_types' => ['card'],
                'line_items' => [
                    [
                        'price_data' => [
                            'currency' => $currency,
                            'product_data' => [
                                'name' => "Payment"
                            ],
                            'unit_amount' => ($amount * 100),
                        ],
                        'quantity' => 1,
                    ]
                ],
                'mode' => 'payment',
                'success_url' => route('stripe.payment.done'),
                'cancel_url' => route('stripe.payment.cancel'),
            ]);
            Session::put('stripe_order_info', [
                'paymentType' => $paymentType,
                'refNo' => $refNo,
                'serviceAmount' => ($amount),
                'trnId' => $session->id,
                'currency' => $session->currency,
                'customerEmail' => $session->customer_email
            ]);
            return ['status' => $session->status, 'redirectUrl' => $session->url];
        } catch (HttpException $ex) {
            return ['status' => $ex->statusCode, 'message' => $ex->getMessage()];
        }
    }

    //no need to pass response param
    public function updateServicePaymentInfo($response)
    {
        $serviceBoockedInfoId = Session::get("stripe_order_info")['refNo'];

        $bookedServiceInfo = SchServiceBookingInfo::where('id', $serviceBoockedInfoId)->first();

        $bookedService = SchServiceBooking::where('sch_service_booking_info_id', $serviceBoockedInfoId)->get();

        $totalServiceAmount = $bookedServiceInfo->total_amount;
        foreach ($bookedService as $service) {
            $paidAmount = floatval($service->service_amount) * (floatval(Session::get("stripe_order_info")['serviceAmount']) / floatval($totalServiceAmount));
            $service->paid_amount = $paidAmount;
            $service->payment_status = ServicePaymentStatus::Paid;
            $service->status = ServiceStatus::Approved;
            $service->update();
        }

        $bookedServiceInfo->payments()->create(
            [
                'payment_type' => PaymentType::Stripe,
                'payment_amount' => Session::get("stripe_order_info")['serviceAmount'],
                'payment_fee' => 0,
                'currency_code' => Session::get("stripe_order_info")['currency'],
                'payee_email_address' => Session::get("stripe_order_info")['customerEmail'],
                'payee_crd_no' => '',
                'payment_create_time' => now(),
                'payment_details' => '',
                'order_id' => Session::get("stripe_order_info")['trnId']
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
        $serviceBoockedId = Session::get("stripe_order_info")['refNo'];
        $bookedService = SchServiceBooking::where('id', $serviceBoockedId)->first();

        $bookedService->paid_amount = floatval(Session::get("stripe_order_info")['serviceAmount']);
        $bookedService->payment_status = ServicePaymentStatus::Paid;
        $bookedService->status = ServiceStatus::Approved;
        $bookedService->update();


        $bookedService->payments()->create(
            [
                'payment_type' => PaymentType::Stripe,
                'payment_amount' => Session::get("stripe_order_info")['serviceAmount'],
                'payment_fee' => 0,
                'currency_code' => Session::get("stripe_order_info")['currency'],
                'payee_email_address' => Session::get("stripe_order_info")['customerEmail'],
                'payee_crd_no' => '',
                'payment_create_time' => now(),
                'payment_details' => '',
                'order_id' => Session::get("stripe_order_info")['trnId']
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
