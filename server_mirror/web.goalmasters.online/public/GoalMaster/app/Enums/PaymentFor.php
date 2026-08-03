<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
final class PaymentFor extends Enum
{
    const ServiceCharge =   1;
    const OrderPayment =   2;
    const ServiceDuePayment = 3;
}
