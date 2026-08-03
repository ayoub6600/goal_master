<?php

namespace App\Http\Repository\Settings;

use App\Models\Settings\CmnProduct;

class ProductRepository
{
    public function getAll()
    {
        return CmnProduct::with('type')->get();        
    }    
}
