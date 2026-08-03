<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
final class OrderStatus extends Enum
{
    const Processing    = 1;
    const Shipped       = 2;
    const Deliverd      = 3;
    const Cancled       = 4;
}
