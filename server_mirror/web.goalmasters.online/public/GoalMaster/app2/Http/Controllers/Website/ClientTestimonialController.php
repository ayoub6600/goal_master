<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Website\SiteClientTestimonial;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ClientTestimonialController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function clientTestimonial()
    {
        return view('website.client-testimonial');
    }

    public function saveClientTestimonial(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => ['required', 'string', 'max:200'],
                'description' => ['required', 'string', 'max:3000'],
                'rating' => ['required', 'int', 'min:1'],
                'image' => 'image|mimes:jpeg,png,jpg,gif|max:512|required'
            ]);

            $data = $request->toArray();
            $image = $request->image;

            if ($image != null) {
                $image = UtilityRepository::saveFile($image, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                $data['image'] = $image;
            }

            if (!$validator->fails()) {
                $data['id']=null;
                $data['created_by'] = Auth::id();
                SiteClientTestimonial::create($data);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function updateClientTestimonial(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => ['required', 'string', 'max:200'],
                'description' => ['required', 'string', 'max:3000'],
                'rating' => ['required', 'int', 'min:1'],
                'image' => 'image|mimes:jpeg,png,jpg,gif|max:512'
            ]);

            $data = $request->toArray();
            $image = $request->image;

            if ($image != null) {
                $image = UtilityRepository::saveFile($image, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                $data['image'] = $image;
            }

            if (!$validator->fails()) {
                $savedData = SiteClientTestimonial::where('id', $request->id)->first();
                if ($savedData != null) {
                    $data['updated_by'] = Auth::id();
                    $data['status'] = $data['status'] ?? 0;
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

    public function deleteClientTestimonial(Request $request)
    {
        try {
            $savedData = SiteClientTestimonial::where('id', $request->id)->first();
            if ($savedData != null) {
                $savedData->delete();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '0', 'data' => ''], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getClientTestimonial()
    {
        try {
            $data = SiteClientTestimonial::select(
                'id',
                'name',
                'description',
                'rating',
                'image',
                'contact_phone',
                'contact_email',
                'client_ref',
                'status'
            )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
