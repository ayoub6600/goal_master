<?php

namespace App\Http\Middleware;

use App\Models\Customer\CmnCustomer;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\URL;

class GuestPhoneNumberVerfication
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next, $redirectToRoute = null)
    {
        $data = $request->all();
        $phone_no = $data['bookingData']['phone_no'];
        $customer = CmnCustomer::where('phone_no', $phone_no)->first();
        dd($customer);

        if (
            !$user ||
            !$customer->is_phone_verified
        ) {
            return $request->expectsJson()
                ? abort(403, 'Your phone number is not verified.')
                : Redirect::guest(URL::route($redirectToRoute ?: 'phone.verification'));
        }

        return $next($request);
    }
}
