<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Website\SitePhotoGallery;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class PhotoGallaryController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function photoGallery()
    {
        return view('website.photo-gallery');
    }

    public function savePhotoGallery(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'image_url' => 'image|mimes:jpeg,png,jpg,gif|max:2048|required'
            ]);

            $data = $request->toArray();
            $image = $request->image_url;

            if ($image != null) {
                $image = UtilityRepository::saveFile($image, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                $data['image_url'] = $image;
            }

            if (!$validator->fails()) {
                $data['id']=null;
                $data['created_by'] = Auth::id();
                $data['order'] = UtilityRepository::emptyOrNullToZero($data['order']);
                SitePhotoGallery::create($data);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function updatePhotoGallery(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'image_url' => 'image|mimes:jpeg,png,jpg,gif|max:2048'
            ]);
            if (!$validator->fails()) {
                $data = $request->toArray();
                $image = $request->image_url;
                if ($image != null) {
                    $image = UtilityRepository::saveFile($image, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                    $data['image_url'] = $image;
                }

                $savedData = SitePhotoGallery::where('id', $request->id)->first();
                if ($savedData != null) {
                    $data['updated_by'] = Auth::id();
                    $data['status'] = $data['status'] ?? 0;
                    $data['order'] = UtilityRepository::emptyOrNullToZero($data['order']);
                    $savedData->update($data);
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function deletePhotoGallery(Request $request)
    {
        try {

            $savedData = SitePhotoGallery::where('id', $request->id)->first();
            if ($savedData != null) {
                $savedData->delete();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '0', 'data' => ''], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getPhotoGallary()
    {
        try {
            $data = SitePhotoGallery::select('id', 'name', 'image_url', 'order', 'status')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
