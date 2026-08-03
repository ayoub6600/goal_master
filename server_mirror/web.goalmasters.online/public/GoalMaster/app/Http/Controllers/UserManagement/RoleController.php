<?php

namespace App\Http\Controllers\UserManagement;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserManagement\SecRole;
use Exception;
use Illuminate\Support\Facades\Validator;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class RoleController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function role(){
        return view('user_management.role');
    }

    /**
     * Summary of createRole
     * Create role
     * Author: kaysar
     * Date: 19-Dec-2020
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function createRole(Request $data)
    {
        try{
            $validator=Validator::make($data->toArray(), [
                 'name' => ['required', 'string', 'max:150','unique:sec_roles'],
                 'isDefaultRole' => ['required','int'],
                 'status' => ['required','int']
             ]);

            if(!$validator->fails()){
                SecRole::create([
               'name' => $data->name,
               'status' => $data->status,
               'created_by'=> auth()->id()
                ]);
                return $this->apiResponse(['status'=>'1','data'=>''],200);
            }
            return $this->apiResponse(['status'=>'500','data'=>$validator->errors()],400);

        }
        catch(Exception $ex){
            return $this->apiResponse(['status'=>'501','data'=>$ex],400);
        }
    }

    /**
     * Summary of getRoleInfo
     * Get all role info
     * Author: Kaysar
     * Date: 19-Dec-2020
     * @return \Illuminate\Http\JsonResponse
     */
    public function getRoleInfo(){
        try{
            $data= DB::table('sec_roles')->select('id','name','is_default_user_role','status','created_at')->get();
            return $this->apiResponse(['status'=>'1','data'=>$data],200);
        }
        catch(QueryException $qx){
            return $this->apiResponse(['status'=>'403','data'=>$qx],400);
        }
    }

    /**
     * Summary of updateRoleInfo
     * Update role info
     * Author: Kaysar
     * Date: 19-Dec-2020
     * @param Request $data
     */
    public function updateRoleInfo(Request $data){
        try{
            $validator=Validator::make($data->toArray(), [
                 'name' => ['required', 'string', 'max:150'],
                 'isDefaultRole' => ['required', 'int'],
                 'status' => ['required','int']
             ]);

            if(!$validator->fails()){
                $role=SecRole::where('id',$data->id)->first();
                $role->name= $data->name;
                $role->is_default_user_role= $data->isDefaultRole;
                $role->updated_by= auth()->id();
                $role->status= $data->status;
                $role->update();
                return $this->apiResponse(['status'=>'1','data'=>''],200);
            }
            return $this->apiResponse(['status'=>'500','data'=>$validator->errors()],400);
        }
        catch(Exception $ex){
            return $this->apiResponse(['status'=>'501','data'=>$ex],400);
        }
    }

    /**
     * Summary of deleteRole
     * Delete one by one role info by role id
     * Author: kaysar
     * Date: 21-dec-2020
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteRole(Request $data)
    {
        try{

            $rtr=SecRole::destroy($data->id);
            return $this->apiResponse(['status'=>'1','data'=>$rtr],200);
        }
        catch(Exception $ex){
            return $this->apiResponse(['status'=>'501','data'=>$ex],400);
        }
    }


    /**
     * Summary of getRoles
     * Get all role info for role permission dropdown
     * Author: Kaysar
     * Date: 21-Dec-2020
     * @return \Illuminate\Http\JsonResponse
     */
    public function getRoles(){
        try{
            $data= DB::table('sec_roles')->select('id','name')->get();
            return $this->apiResponse(['status'=>'1','data'=>$data],200);
        }
        catch(QueryException $qx){
            return $this->apiResponse(['status'=>'403','data'=>$qx],400);
        }
    }
}
