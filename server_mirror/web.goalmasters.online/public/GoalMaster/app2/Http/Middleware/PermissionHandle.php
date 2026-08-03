<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Routing\Redirector;
use App\Http\Controllers\HomeController;
use Illuminate\Support\Facades\Auth;

class PermissionHandle
{
    /**
     * This method check route permission
     * Author: kaysar
     * Date: 10-01-2021
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        $userId=Auth::id();
        $userRoleId=DB::table('sec_user_roles')->where('sec_user_id',$userId)->select('sec_role_id')->first();
        if($userRoleId!=null){
            if(!$request->ajax()){                
                //page load request
                $isRresourcePermission=DB::table('sec_resource_permissions as rp')->join('sec_resources as r','r.id','=','rp.sec_resource_id')
                    ->where('rp.sec_role_id',$userRoleId->sec_role_id)
                    ->where('r.method',$request->route()->getName())->where('rp.status',1)->count();
                if($isRresourcePermission==null){
                    $isRresourcePermission=DB::table('sec_role_permissions as rp')->join('sec_role_permission_infos as rpi','rp.sec_role_permission_info_id','=','rpi.id')
                   ->where('rp.sec_role_id',$userRoleId->sec_role_id)
                   ->where('rpi.route_name',$request->route()->getName())->where('rp.status',1)->count();
                }

                if($isRresourcePermission!=null){
                    //permission grant
                    return $next($request);

                }else{
                    $msg = 'You have no permission';
                    //you have no permission in sec_resource_permission table for this role
                    return  redirect()->route('error.display',['msg'=>$msg]);
                }

            }else{                
                //ajax request
                $isRollPermission=DB::table('sec_role_permissions as rp')->join('sec_role_permission_infos as rpi','rp.sec_role_permission_info_id','=','rpi.id')
                   ->where('rp.sec_role_id',$userRoleId->sec_role_id)
                   ->where('rpi.route_name',$request->route()->getName())->where('rp.status',1)->count();
                if($isRollPermission==null){
                    $isRollPermission=DB::table('sec_resource_permissions as rp')->join('sec_resources as r','r.id','=','rp.sec_resource_id')
                    ->where('rp.sec_role_id',$userRoleId->sec_role_id)
                    ->where('r.method',$request->route()->getName())->where('rp.status',1)->count();
                }

                if($isRollPermission!=null){
                    //permission grant
                    return $next($request);

                }else{
                    //you have no permission in sec_role_permission table for this role
                    return response()->json(['status'=>503,'data'=>'You have no permission'],400);
                }
            }
        }else{
            //you have not set user role
            $msg = 'You do not have assign user role';
            return  redirect()->route('error.display',['msg'=>$msg]);
        }
    }
}
