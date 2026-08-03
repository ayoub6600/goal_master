<?php

namespace App\Http\Middleware;

use App\Models\Customer\CmnCustomer;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\URL;

class EnsurePhoneIsVerified
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */

        public function handle($request, Closure $next, $redirectToRoute = null)
    {
        $user = $request->user();
        $customer = null;

        if ($user && $user->user_type == 1) {
            return $next($request);
        }

        if ($request->user() && $user->user_type != 1) {
            $customer = CmnCustomer::where('user_id', $user->id)->first();
        }

        if (!$user || !$customer->is_phone_verified) {
            return $request->expectsJson()
                ? abort(403, 'Your phone number is not verified.')
                : Redirect::guest(URL::route($redirectToRoute ?: 'phone.verification'));
        }

        return $next($request);
    }
    
}
