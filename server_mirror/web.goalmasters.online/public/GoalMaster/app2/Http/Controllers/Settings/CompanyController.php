<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use App\Models\Settings\CmnCompany;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CompanyController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function company()
    {
        return view('settings.company');
    }

    /**
     * Summary of saveCompany
     * Author: kaysar
     * Date: 22-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function companyStore(Request $data)
    {

        try {
            $validator = Validator::make($data->all(), [
                'name' => ['required', 'string', 'max:50'],
                'address' => ['required', 'string', 'max:100'],
                'mobile' => ['required', 'max:11'],
                'phone' => ['required', 'max:11'],
                'email' => ['required', 'email'],
                'web_address' => ['required', 'string'],
            ]);

            if (!$validator->fails()) {

                $data['created_by'] =auth()->id();

                CmnCompany::create($data->toArray());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Summary of updateCompany
     * Author: kaysar
     * Date: 22-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function companyUpdate(Request $data)
    {

        try {

            $validator = Validator::make($data->all(), [
                'name' => ['required', 'string', 'max:50'],
                'address' => ['required', 'string', 'max:100'],
                'mobile' => ['required', 'max:11'],
                'phone' => ['required', 'max:11'],
                'email' => ['required', 'email',],
                'web_address' => ['required', 'string'],

            ]);

            if (!$validator->fails()) {

                $data['updated_by'] = auth()->id();

                CmnCompany::where('id', $data->id)->update($data->toArray());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function companyGet()
    {
        try {
            $data = CmnCompany::select(
                'id',
                'name',
                'address',
                'phone',
                'mobile',
                'email',
                'web_address'
            )->first();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
