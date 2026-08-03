<?php

namespace App\Http\Repository\Payment;

use App\Contract\PaymentInterface;

class PaymentGatewayRepository
{
    private $paymentGatway;
    public function __construct(PaymentInterface $paymentInterface)
    {
        $this->paymentGatway = $paymentInterface;
    }

    public function checkout($amount, $paymentType, $refNo)
    {
        return $this->paymentGatway->checkout($amount, $paymentType, $refNo);
    }

    public function updateServicePaymentInfo($response)
    {
        return $this->paymentGatway->updateServicePaymentInfo($response);
    }

    public function updateServiceDuePayment($response)
    {
        return $this->paymentGatway->updateServiceDuePayment($response);
    }
    
}
