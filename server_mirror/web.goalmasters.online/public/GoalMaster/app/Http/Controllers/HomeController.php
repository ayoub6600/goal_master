<?php

namespace App\Http\Controllers;

use App\Enums\PaymentType;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }


    public function errorDisplay(Request $req)
    {
        return view('error_display', $req);
    }

}
