<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class Manager
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
       try {
        if (auth()->user()->user_type != 1) {
            return response()->json(['status' => 'false', 'message' => __('apiValidation.Unauthorized')], 403);
        }
        return $next($request);
       } catch (\Throwable $th) {
        return response()->json(['status'=>'false','message'=>$th->getMessage()], 500);
       }
       
    }
}
