<?php

namespace App\Http\Controllers\UserManagement;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserManagement\SecUserRole;
use App\Models\UserManagement\SecRolePermission;
use App\Models\UserManagement\SecResource;
use App\Models\UserManagement\SecResourcePermission;
use Exception;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RolePermissionController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Summary of rolePermission
     * Author: kaysar
     * Date: 23-dec-2020
     * @param Request $request
     * @return \Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View
     */
    public function rolePermission(Request $request){
        $resourceList = $this->getResourceMenuList($request->id);
        return view('user_management.role_permission',['resourceList' => $resourceList]);
    }


    /**
     * Summary of getResourceMenuList
     * Author: kaysar
     * Date: 23-dec-2020
     * @return mixed
     */
    public function getResourceMenuList($roleId){
        $user=auth()->user();
        if($user->is_sys_adm==1){
            $resource=DB::table('sec_resources as rs')
                ->leftJoin('sec_resource_permissions as rsp', function($query) use($roleId){
                    $query->on('rs.id' ,'=', 'rsp.sec_resource_id');
                    $query->where('rsp.sec_role_id',$roleId);
                })->where('rs.status',1)
            ->select('rs.id',
                     'rs.display_name as org_display_name',
                     'rsp.display_name',
                     'rs.level',
                     'rs.serial',
                     'rs.sec_module_id',
                     'rs.sec_resource_id',
                     'rsp.id as sec_resource_permission_id',
                     'rsp.status'
                    )->orderBy('rs.serial')->get();
            $rolePermissions=DB::table('sec_role_permission_infos as rpi')
                    ->leftJoin('sec_role_permissions as rp', function($query) use($roleId){
                        $query->on('rpi.id','=','rp.sec_role_permission_info_id')
                            ->where('rp.sec_role_id',$roleId);
                    })->whereIn('rpi.sec_resource_id',$resource->pluck('id'))
                    ->select('rpi.id','rpi.permission_name','rp.status','rpi.sec_resource_id')->get();

            $resource->each(function ($collection, $resource) use($rolePermissions) {
                $collection->role=$rolePermissions->where('sec_resource_id',$collection->id);
            });
            return $resource;
        }
        else{
            $resource=DB::table('sec_resources as rs')
                ->join('sec_resource_permissions as rspa', function($query) use($user){
                    $query->on('rs.id' ,'=', 'rspa.sec_resource_id')
                        ->where('rspa.sec_role_id',SecUserRole::where('sec_user_id',$user->id)->first()->sec_role_id)
                        ->where('rspa.status',1);
                })->leftJoin('sec_resource_permissions as rspu',function($query) use($roleId){
                    $query->on('rspa.sec_resource_id','=','rspu.sec_resource_id')
                        ->where('rspu.sec_role_id',$roleId);
                })
            ->select('rs.id',
                     'rs.display_name as org_display_name',
                     'rspa.display_name',
                     'rs.level',
                     'rs.serial',
                     'rs.sec_module_id',
                     'rs.sec_resource_id',
                     'rspa.id as sec_resource_permission_id',
                     'rspu.status'
                    )->orderBy('rs.serial')->get();
              $rolePermissions=DB::table('sec_role_permission_infos as rpi')
                    ->leftJoin('sec_role_permissions as rp', function($query) use($roleId){
                        $query->on('rpi.id','=','rp.sec_role_permission_info_id')->where('rp.sec_role_id',$roleId);
                    })->whereIn('rpi.sec_resource_id',$resource->pluck('id'))
                    ->select('rpi.id','rpi.permission_name','rp.status','rpi.sec_resource_id')->get();

            $resource->each(function ($collection, $resource) use($rolePermissions) {
                $collection->role=$rolePermissions->where('sec_resource_id',$collection->id);
            });
            return $resource;

        }
    }

    /**
     * Summary of saveOrUpdatePermission
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function saveOrUpdatePermission(Request $request){
        DB::beginTransaction();
        try{

            $userId=auth()->id();
            $isSysAdminRole=false;
            $roleId=$request->permissionData["roleId"];
            
            if(DB::table('sec_user_roles as ur')->join('users as u','ur.sec_user_id','=','u.id')->where('u.is_sys_adm',1)->where('ur.sec_role_id',$roleId)->count()>0){
                $isSysAdminRole=true;
            }

            $resourceLst=$request->permissionData["resource"];
            $rolePermissionLst=$request->permissionData["rolePermission"];
            $resourceM=SecResource::get();
            $savedResourse=SecResourcePermission::where('sec_role_id',$roleId)->get();
            $savedRolePermission=SecRolePermission::where('sec_role_id',$roleId)->get();


            //resource permission
            $secResourcePermission= array();
            foreach($resourceLst as $rs){
                $savedRes = $savedResourse->where('sec_resource_id',$rs["SecResourceId"])->first();
                if ($savedRes != null)
                {
                    if ($savedRes->status != $rs["Status"])
                    {
                        //update
                        $resStatus=($isSysAdminRole==true)?1:$rs["Status"];
                        $savedRes->status = $resStatus;
                        $savedRes->updated_by = $userId;
                        $savedRes->updated_at = Carbon::now();
                        $savedRes->update();
                    }
                }
                else
                {
                    //insert
                    $extingRes = $resourceM->where('id',$rs["SecResourceId"])->first();
                    $secResourcePermission[]= [
                        'display_name' => $extingRes->display_name,
                        'created_by' => $userId,
                        'created_at' => Carbon::now(),
                        'sec_resource_id' => $extingRes->id,
                        'sec_role_id' =>$roleId,
                        'status' => $extingRes->status
                        ];
                }
            }

            SecResourcePermission::insert($secResourcePermission);


            //role permission
            $secRolePermission=array();
            foreach ($rolePermissionLst as $rl)
            {
                $savedRolePer = $savedRolePermission->where('sec_role_permission_info_id', $rl["SecRolePermissionInfoId"])->first();

                if ($savedRolePer != null)
                {
                    if ($savedRolePer->status != $rl["Status"])
                    {
                        //update
                        $rollStatus=($isSysAdminRole==true)?1:$rl["Status"];
                        $savedRolePer->status = $rollStatus;
                        $savedRolePer->updated_by = $userId;
                        $savedRolePer->updated_at = Carbon::now();
                        $savedRolePer->update();
                    }
                }
                else
                {
                    //insert
                    $secRolePermission[]=[
                        'sec_role_id' => $roleId,
                        'sec_role_permission_info_id' => $rl["SecRolePermissionInfoId"],
                        'status' => $rl["Status"],
                        'created_by' => $userId,
                        'created_at' => Carbon::now(),
                        ];
                }
            }
            SecRolePermission::insert($secRolePermission);
            DB::commit();
            return $this->apiResponse(['status'=>1,'data'=>''],200);
        }
        catch(Exception $ex){
            DB::rollBack();
            return $this->apiResponse(['status'=>'501','data'=>$ex],400);
        }

    }


    /*
     *This is Update resource display name
     * Author: kaysar
     * Date: 01-Jan-2021
     * @param Request $request
     * @return void
     */
    public function updateResourceDisplayName(Request $request){
        try{
            $resource=SecResourcePermission::where('sec_role_id',$request->roleId)->where('sec_resource_id',$request->resourceId)->first();
            if ($resource != null)
            {

                if ($resource->display_name != $request->displayName)
                {
                    $resource->display_name = $request->displayName;
                    $resource->update();
                    return $this->apiResponse(['status'=>1,'data'=>''],200);
                }
                else
                {
                    return $this->apiResponse(['status'=>-1011,'data'=>''],200);
                }
            }
            return $this->apiResponse(['status'=>-1010,'data'=>''],200);
        }
        catch(Exception $ex){
            return $this->apiResponse(['status'=>'501','data'=>$ex],400);
        }
    }

    public function getMenuList(){
        try{

            $menuLst =DB::table('sec_resource_permissions as rsp')
            ->join('sec_resources as rs','rsp.sec_resource_id','=','rs.id')
                              ->where('rsp.sec_role_id',DB::table('sec_user_roles')->where('sec_user_id',auth()->id())->first()->sec_role_id)
                              ->where('rsp.status', 1)
                              ->select('rs.id','rs.level', 'rs.serial','rsp.sec_resource_id', 'rs.method', 'rsp.display_name', 'rs.sec_resource_id as resource_id','rs.icon')
                              ->orderBy('rs.serial')->get();

            return $menuLst;
        }
        catch(Exception $ex){
            return null;
        }
    }

}
