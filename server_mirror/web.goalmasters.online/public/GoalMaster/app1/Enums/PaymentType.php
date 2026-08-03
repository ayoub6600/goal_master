<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
final class PaymentType extends Enum
{
    const LocalPayment =   1;
    const Paypal =   2;
    const Stripe =   3;
    const UserBalance =   4;



    public static function getKey($value): string
    {
        return __([
            self::LocalPayment => 'status.Cash',
            self::Paypal => 'status.Paypal',
            self::Stripe => 'status.Stripe',
            self::UserBalance => 'status.UserBalance',
        ][$value] ?? 'status.Unknown');
    }

    public static function getKeyArabic($value): string
    {
        return __([
            self::LocalPayment => 'نقدي',
            self::Paypal => 'بايبال',
            self::Stripe => 'استراب',
            self::UserBalance => 'رصيد المستخدم',
        ][$value] ?? 'غير معروف');
    }
}
