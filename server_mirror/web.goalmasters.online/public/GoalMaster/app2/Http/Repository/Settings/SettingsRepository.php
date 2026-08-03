<?php

namespace App\Http\Repository\Settings;

use App\Models\Customer\CmnCustomer;
use App\Models\Payment\CmnCurrencySetup;

class SettingsRepository
{
    public function cmnCurrency()
    {
        $data = CmnCurrencySetup::select('value')->first();
        if ($data != null)
            return $data->value;
        return "";
    }

    public function getCustomer($userId)
    {
        $data = CmnCustomer::where('user_id', $userId)
            ->select(
                'id',
                'user_id',
                'full_name',
                'phone_no',
                // 'email',
                'dob',
                'country',
                'state',
                'postal_code',
                'city',
                'street_address',
                'street_number',
            )->first();
            return $data;
    }
}
