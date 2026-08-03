<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Models\Website\SiteTermsAndCondition;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class TermsAndConditionController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function termsAndCondition()
    {
        return view('website.terms-and-condition',['termsCondition'=>$this->getTermsAndCondition()]);
    }

    public function saveOrUpdateTermsAndCondition(Request $data)
    {
        try {
            $validator = Validator::make($data->all(), [
                'details' => ['required']
            ]);
         
            if (!$validator->fails()) {
                $savedData = SiteTermsAndCondition::first();

                if ($savedData != null) {
                    $data['updated_by'] = Auth::id();
                    $data['status'] = $data['status']??0;
                    $savedData->update($data->all());
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                } else {
                    //insert
                    if (!$validator->fails()) {
                        $data['created_by'] = Auth::id();
                        $data['status'] = $data['status']??0;
                        SiteTermsAndCondition::create($data->all());
                        return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                    }
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getTermsAndCondition()
    {
        try {
            $data = SiteTermsAndCondition::select(
                'details',
                'status'
            )->first();
            return $data;
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
