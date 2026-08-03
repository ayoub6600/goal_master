<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
final class EmployeeStatus extends Enum
{
    const PublicStaff =   1;
    const PrivateStaff =   2;
    const DisableStaff = 3;
}
