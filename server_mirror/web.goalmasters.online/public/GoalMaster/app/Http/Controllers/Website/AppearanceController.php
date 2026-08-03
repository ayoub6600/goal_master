<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Website\SiteAppearance;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AppearanceController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }
    public function appearance()
    {
        return view('website.appearance', ['appearance' => $this->getAppearance()]);
    }

    public function saveOrUpdateAppearance(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'app_name' => ['required', 'string', 'max:50'],
                'theam_color' => ['required', 'string', 'max:10'],
                'theam_menu_color2' => ['required', 'string', 'max:10'],
                'theam_hover_color' => ['required', 'string', 'max:10'],
                'theam_active_color' => ['required', 'string', 'max:10'],
                'contact_email' => ['required'],
                'contact_phone' => ['required'],
                'contact_web' => ['required'],
                'address' => ['required'],
                'logo' => 'image|mimes:jpeg,png,jpg,gif|max:256',
                'background_image' => 'image|mimes:jpeg,png,jpg,gif|max:1024',
                'login_background_image' => 'image|mimes:jpeg,png,jpg,gif|max:1024'
            ]);

            $data = $request->toArray();
            $icon = $request->icon;
            $logo = $request->logo;
            $backgroundImage = $request->background_image;
            $loginBackgroundImage = $request->login_background_image;

            if ($icon != null) {
                $icon = UtilityRepository::saveFile($icon, ['image/x-icon', 'image/icon']);
                $data['icon'] = $icon;
            }
            if ($logo != null) {
                $logo = UtilityRepository::saveFile($logo, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                $data['logo'] = $logo;
            }
            if ($backgroundImage != null) {
                $backgroundImage = UtilityRepository::saveFile($backgroundImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                $data['background_image'] = $backgroundImage;
            }
            if ($loginBackgroundImage != null) {
                $loginBackgroundImage = UtilityRepository::saveFile($loginBackgroundImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                $data['login_background_image'] = $loginBackgroundImage;
            }

            if (!$validator->fails()) {
                $savedData = SiteAppearance::first();

                if ($savedData != null) {
                    //update
                    if ($icon == null)
                        unset($request['icon']);
                    if ($logo == null)
                        unset($request['logo']);
                    if ($backgroundImage == null)
                        unset($request['background_image']);
                    if ($loginBackgroundImage == null)
                        unset($request['login_background_image']);

                    $data['updated_by'] = Auth::id();
                    $savedData->update($data);
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                } else {
                    //insert
                    $validator = Validator::make($request->all(), [
                        'logo' => ['required'],
                        'background_image' => ['required']
                    ]);
                    if (!$validator->fails()) {
                        $data['created_by'] = Auth::id();
                        SiteAppearance::create($data);
                        return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                    }
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getAppearance()
    {
        try {        
            $data = SiteAppearance::select(
                'app_name',
                'logo',
                'icon',
                'motto',
                'theam_color',
                'theam_menu_color2',
                'theam_hover_color',
                'theam_active_color',
                'facebook_link',
                'youtube_link',
                'twitter_link',
                'instagram_link',
                'about_service',
                'contact_email',
                'contact_phone',
                'contact_web',
                'address',
                'background_image',
                'login_background_image',
                'meta_title',
                'meta_description',
                'meta_keywords',
            )->first();
            return $data;
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
