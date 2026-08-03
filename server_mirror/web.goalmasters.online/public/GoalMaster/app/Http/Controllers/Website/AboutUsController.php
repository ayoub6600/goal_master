<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\Website\SiteAboutUs;
use ErrorException;
use Exception;
use Illuminate\Support\Facades\Auth;

use function PHPUnit\Framework\throwException;

class AboutUsController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function aboutUs()
    {
        return view('website.about-us');
    }

    public function saveAboutUs(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => ['required', 'string', 'max:200'],
                'details' => ['required', 'string', 'max:3000'],
                'image_url' => 'image|mimes:jpeg,png,jpg,gif|max:512|required'
            ]);

            if(SiteAboutUs::exists()){
             throw new ErrorException("You are not able to add new item.");
            }

            $data = $request->toArray();
            $image = $request->image_url;

            if ($image != null) {
                $image = UtilityRepository::saveFile($image, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                $data['image_url'] = $image;
            }

            if (!$validator->fails()) {
                $data['id']=null;
                $data['created_by'] = Auth::id();
                $data['order'] =UtilityRepository::emptyOrNullToZero($data['order']);
                SiteAboutUs::create($data);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        }catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function updateAboutUs(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => ['required', 'string', 'max:200'],
                'details' => ['required', 'string', 'max:3000'],
                'image_url' => 'image|mimes:jpeg,png,jpg,gif|max:512'
            ]);

            $data = $request->toArray();
            $image = $request->image_url;

            if ($image != null) {
                $image = UtilityRepository::saveFile($image, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                $data['image_url'] = $image;
            }

            if (!$validator->fails()) {
                $savedData = SiteAboutUs::where('id', $request->id)->first();
                if ($savedData != null) {
                    $data['updated_by'] = Auth::id();
                    $data['order'] = UtilityRepository::emptyOrNullToZero($data['order']);
                    $data['status'] =$data['status']??0;
                    $savedData->update($data);
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        }catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function deleteAboutUs(Request $request)
    {
        try {

            $savedData = SiteAboutUs::where('id', $request->id)->first();
            if ($savedData != null) {
                $savedData->delete();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '0', 'data' => ''], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getAboutUs()
    {
        try {
            $data = SiteAboutUs::select('id', 'title', 'details', 'order', 'image_url', 'status')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
