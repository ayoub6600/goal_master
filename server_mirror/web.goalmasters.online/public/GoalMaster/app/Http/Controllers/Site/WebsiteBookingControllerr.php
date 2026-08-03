<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class WebsiteBookingControllerr extends Controller
{
    public function appoinmentBooking(){
        return view('site.booking');
    }

    public function bookingCalendar(){
        return view('site.emb-booking-calendar');
    }
}
