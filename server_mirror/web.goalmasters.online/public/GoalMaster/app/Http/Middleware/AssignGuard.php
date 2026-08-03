<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Symfony\Component\HttpFoundation\Response;
use Tymon\JWTAuth\Http\Middleware\BaseMiddleware;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;

class AssignGuard extends BaseMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, $guard = null): Response
    {
        if ($guard != null) {
            auth()->shouldUse($guard);
            $token = $request->header('Authorization');
    
            if ($request->is('api/advertise')) {
                try {
                    if ($token) {
                        $request->headers->set('Authorization', 'Bearer ' . $token, true);
                        JWTAuth::parseToken()->authenticate();
                    }
                } catch (TokenExpiredException $e) {
                    return $next($request);
                } catch (JWTException $e) {
                    return $next($request);
                }
    
                return $next($request);
            }
    
            $request->headers->set('token', (string) $token, true);
            $request->headers->set('Authorization', 'Bearer ' . $token, true);
    
            try {
                JWTAuth::parseToken()->authenticate();
            } catch (TokenExpiredException $e) {
                return response()->json(['status' => "false", 'message' => 'Unauthenticated user ' . $e->getMessage()], 401);
            } catch (JWTException $e) {
                return response()->json(['status' => "false", 'message' => 'Token Invalid ' . $e->getMessage()], 401);
            }
        }
    
        return $next($request);
    }
    
}
