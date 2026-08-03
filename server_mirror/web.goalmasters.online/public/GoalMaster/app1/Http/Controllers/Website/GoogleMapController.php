<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Models\Website\SiteGoogleMap;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class GoogleMapController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }
    public function googleMap()
    {
        return view('website.google-map', ['mapSettings' => $this->getGoogleMap()]);
    }

    public function saveOrUpdateGoogleMap(Request $data)
    {
        try {
            $validator = Validator::make($data->all(), [
                'lat' => ['required', 'string', 'max:18'],
                'long' => ['required', 'string', 'max:18'],
                'map_key' => ['required', 'string', 'max:500']
            ]);

         
            if (!$validator->fails()) {
                $savedData = SiteGoogleMap::first();

                if ($savedData != null) {
                    $data['updated_by'] = Auth::id();
                    $savedData->update($data->all());
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                } else {
                    //insert
                    if (!$validator->fails()) {
                        $data['created_by'] = Auth::id();
                        SiteGoogleMap::create($data->all());
                        return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                    }
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getGoogleMap()
    {
        try {
            $data = SiteGoogleMap::select(
                'lat',
                'long',
                'map_key'
            )->first();
            return $data;
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
