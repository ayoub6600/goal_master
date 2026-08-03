<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class ApiPermissionHandle
{
    /**
     * Handle an incoming request for API.
     */
    public function handle(Request $request, Closure $next)
    {
        $userId = Auth::guard('api')->id();
        if (!$userId) {
            return response()->json([
                'status' => false,
                'message' => 'Unauthorized: Please login first'
            ], 401);
        }

        $userRole = DB::table('sec_user_roles')
            ->where('sec_user_id', $userId)
            ->select('sec_role_id')
            ->first();

        if (!$userRole) {
            return response()->json([
                'status' => false,
                'message' => 'Access Denied: No role assigned'
            ], 403);
        }

        $routeName = $request->route()->getName(); 

        $hasPermission = DB::table('sec_resource_permissions as rp')
            ->join('sec_resources as r', 'r.id', '=', 'rp.sec_resource_id')
            ->where('rp.sec_role_id', $userRole->sec_role_id)
            ->where('r.method', $routeName)
            ->where('rp.status', 1)
            ->exists();

        if (!$hasPermission) {
            $hasPermission = DB::table('sec_role_permissions as rp')
                ->join('sec_role_permission_infos as rpi', 'rp.sec_role_permission_info_id', '=', 'rpi.id')
                ->where('rp.sec_role_id', $userRole->sec_role_id)
                ->where('rpi.route_name', $routeName)
                ->where('rp.status', 1)
                ->exists();
        }

        if (!$hasPermission) {
            return response()->json([
                'status' => false,
                'message' => 'Forbidden: You do not have permission to access this resource'
            ], 403);
        }

        return $next($request);
    }
}
