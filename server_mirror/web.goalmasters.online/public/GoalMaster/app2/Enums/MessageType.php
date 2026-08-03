<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
final class MessageType extends Enum
{
    const MessageOnly =   1;
    const ServiceDone =   2;
    const ServiceCancel =   3;
    const ServiceStatus =   4;
    const ServiceConfirm =   5;
    const OrderPlace=6;
}
