<?php

namespace App\Contract;

interface PaymentInterface
{
    public function checkout($amount, $paymentType, $refNo);
    public function updateServicePaymentInfo($response);
    public function updateServiceDuePayment($response);
}