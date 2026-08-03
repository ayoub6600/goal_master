<?php

namespace App\Http\Middleware;

use App\Models\Customer\CmnCustomer;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class EnsurePhoneNotVerified
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle($request, Closure $next)
    {
        $user = $request->user();

        if (!$user) {
            return redirect()->route('login');
        }
        if ($user->user_type == 1) {
            return redirect('/');
        }
        $customer = CmnCustomer::where('user_id', $user->id)->first();
        if ($customer->is_phone_verified) {
            return redirect('/');
        }
        return $next($request);
    }
}
