<?php

namespace App\Models\Payment;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CmnCurrencySetup extends Model
{
   protected $fillable = [
      'id',
      'name',
      'value'
  ];
}
