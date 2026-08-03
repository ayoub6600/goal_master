<?php

namespace App\Http\Controllers\UserManagement;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use Illuminate\Http\Request;
use Exception;
use Illuminate\Database\QueryException;
use App\Models\UserManagement\SecResource;
use App\Models\UserManagement\SecRolePermissionInfo;
use Illuminate\Support\Facades\Validator;

class AddMenuAndPermission extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function addMenuAndPermission()
    {
        return view('user_management.add_menu_and_permission');
    }

    /**
     * This method return all menu and permission list
     * Author: kaysar
     * Date: 20-Jan-2021
     * @return \Illuminate\Http\JsonResponse
     */
    public function getMenuAndPermission()
    {
        try {
            $data = SecResource::with('rolePermissionInfos')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (QueryException $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }


    /**
     * This Method Create new menu
     * Author: kaysar
     * Date: 20-Jan-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function createResource(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:250'],
                'displayName' => ['string', 'max:250'],
                'menuSerial' => ['required', 'int'],
                'level' => ['required', 'int'],
                'status' => ['required', 'int']
            ]);

            if (!$validator->fails()) {
                SecResource::create([
                    'id' => null,
                    'name' => $data->name,
                    'display_name' => $data->displayName,
                    'sec_resource_id' =>UtilityRepository::emptyToNull($data->secResourceId),
                    'sec_module_id' => 1,
                    'serial' => $data->menuSerial,
                    'level' => $data->level,
                    'icon' => $data->faIcon,
                    'method' => $data->routeName ?? "",
                    'status' => $data->status,
                    'created_by' => auth()->id()
                ]);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    /**
     * This Method Update menu
     * Author: kaysar
     * Date: 20-Jan-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateResource(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:250'],
                'displayName' => ['string', 'max:250'],
                'menuSerial' => ['required', 'int'],
                'level' => ['required', 'int'],
                'status' => ['required', 'int']
            ]);

            if (!$validator->fails()) {
                SecResource::where('id', $data->id)
                    ->update([
                        'name' => $data->name,
                        'display_name' => $data->displayName,
                        'sec_resource_id' => $data->secResourceId==""?null:$data->secResourceId,
                        'sec_module_id' => 1,
                        'serial' => $data->menuSerial,
                        'level' => $data->level,
                        'icon' => $data->faIcon ?? "",
                        'method' => $data->routeName ?? "",
                        'status' => $data->status,
                        'updated_by' => auth()->id()
                    ]);

                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * This Method delete menu
     * Author: kaysar
     * Date: 20-Jan-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteResource(Request $data)
    {
        try {

            $rtr = SecResource::where('id', $data->id)->delete();
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }






    /**
     * This Method create new permission
     * Author: kaysar
     * Date: 20-Jan-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function createPermission(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'secResourceId' => ['required', 'int'],
                'permissionName' => ['required', 'string', 'max:150'],
                'permissionRouteName' => ['required', 'string', 'max:250'],
                'status' => ['required', 'int']
            ]);

            if (!$validator->fails()) {
                SecRolePermissionInfo::create([
                    'sec_resource_id' => $data->secResourceId,
                    'permission_name' => $data->permissionName,
                    'route_name' => $data->permissionRouteName,
                    'status' => $data->status,
                    'created_by' => auth()->id()
                ]);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    /**
     * This method update permission
     * Author: kaysar
     * Date: 20-Jan-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function updatePermission(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'secResourceId' => ['required', 'int'],
                'permissionName' => ['required', 'string', 'max:150'],
                'permissionRouteName' => ['required', 'string', 'max:250'],
                'status' => ['required', 'int']
            ]);

            if (!$validator->fails()) {
                SecRolePermissionInfo::where('id', $data->id)
                    ->update([
                        'sec_resource_id' => $data->secResourceId,
                        'permission_name' => $data->permissionName,
                        'route_name' => $data->permissionRouteName,
                        'status' => $data->status
                    ]);

                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    /**
     * This method delete permission
     * Author: kaysar
     * Date: 20-Jan-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function deletePermission(Request $data)
    {
        try {

            $rtr = SecRolePermissionInfo::where('id', $data->id)->delete();
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
}
