<?php

namespace App\Services;

class OTPService
{
  public static function generateCode($length = 6)
  {
    return rand(pow(10, $length - 1), pow(10, $length) - 1);
  }
}
