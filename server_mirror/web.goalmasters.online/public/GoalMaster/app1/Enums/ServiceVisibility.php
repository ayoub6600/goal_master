<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
final class ServiceVisibility extends Enum
{
    const PublicService =   1;
    const PrivateService =   2;
}
