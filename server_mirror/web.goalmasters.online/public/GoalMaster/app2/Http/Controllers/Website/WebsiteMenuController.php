<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Models\Website\SiteMenu;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class WebsiteMenuController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }



    public function websiteMenu()
    {
        return view('website.website-menu');
    }

    public function saveWebsiteMenu(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => ['required', 'string', 'max:200'],
                'route' => ['required', 'string', 'max:3000']
            ]);

            if (!$validator->fails()) {
                $request['id'] = null;
                $request['created_by'] = Auth::id();
                $request['site_menu_id'] = $request->site_menu_id ?? 0;
                SiteMenu::create($request->all());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function updateWebsiteMenu(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => ['required', 'string', 'max:200'],
                'route' => ['required', 'string', 'max:3000']
            ]);

            if (!$validator->fails()) {
                $savedData = SiteMenu::where('id', $request->id)->first();
                if ($savedData != null) {
                    $data = $request->all();
                    if ($request->id <= 8) {
                        $data['route'] = $savedData->route;
                    }
                    $data['updated_by'] = Auth::id();
                    $data['status'] = $data['status'] ?? 0;
                    $data['site_menu_id'] = $data['site_menu_id'] ?? 0;
                    $savedData->update($data);
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function deleteWebsiteMenu(Request $request)
    {
        try {

            $savedData = SiteMenu::where('id', $request->id)->first();
            if ($savedData != null) {
                if($savedData->id<=8)
                    throw new ErrorException("You can't delete default menu, make enable/disable menu by edit.");                
                $savedData->delete();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '0', 'data' => ''], 200);
        }catch(ErrorException $ex){
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        }
         catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getWebsiteMenu()
    {
        try {
            $data = SiteMenu::leftJoin('site_menus as sm', 'site_menus.site_menu_id', '=', 'sm.id')->select(
                'site_menus.id',
                'site_menus.site_menu_id',
                'site_menus.name as c_name',
                'sm.name as p_name',
                'site_menus.order',
                'site_menus.status',
                'site_menus.route',
                'site_menus.remarks'
            )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
