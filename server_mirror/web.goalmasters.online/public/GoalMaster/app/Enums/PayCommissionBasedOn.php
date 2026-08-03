<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
final class PayCommissionBasedOn extends Enum
{
    const BasicSalary =   1;
    const ServiceAmount =   2;
}
