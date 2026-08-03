<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static OptionOne()
 * @method static static OptionTwo()
 * @method static static OptionThree()
 */
namespace App\Enums;

use BenSampo\Enum\Enum;

final class UserType extends Enum
{
    const SystemUser = 1;
    const WebsiteUser = 2;

    const SystemAdmin = 1;

    public static function getById($id)
    {
        $type = collect(self::getInstances())->firstWhere('value', $id);
        return $type ? ['id' => $type->value, 'name' => $type->description] : null;
    }
    


    
}
