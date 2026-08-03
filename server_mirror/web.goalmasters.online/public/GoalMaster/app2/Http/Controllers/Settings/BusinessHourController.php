<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use App\Models\Settings\CmnBusinessHour;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use DB;

class BusinessHourController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function business()
    {
        return view('settings.business-hour');
    }


    /**
     * Summary of saveBusiness
     * Author: kaysar
     * Date: 22-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function businessHourStore(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), []);

            if (!$validator->fails()) {


                $count = CmnBusinessHour::where('cmn_branch_id', $data->cmn_branch_id)->count();
                if ($count == 0) {
                    $businessHour = array();
                    foreach ($data->business as $key => $value) {
                        $businessHour[] = [
                            "cmn_branch_id" => $data->cmn_branch_id,
                            "day" => $value["day"],
                            "start_time" => $value["start_time"],
                            "end_time" => $value["end_time"],
                            "is_off_day" => $value["is_off_day"] ?? 0,
                            "created_by" => auth()->id()
                        ];
                    }
                    CmnBusinessHour::insert($businessHour);
                } else {

                    $businessHour = array();
                    foreach ($data->business as $key => $value) {

                        CmnBusinessHour::where('cmn_branch_id', $data->cmn_branch_id)
                            ->where('id', $value["id"])
                            ->update([
                                "cmn_branch_id" => $data->cmn_branch_id,
                                "day" => $value["day"],
                                "start_time" => $value["start_time"],
                                "end_time" => $value["end_time"],
                                "is_off_day" => $value["is_off_day"] ?? 0,
                                "created_by" => auth()->id()
                            ]);
                    }
                }
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex->getMessage()], 400);
        }
    }

    /**
     * Summary of updateBusiness
     * Author: kaysar
     * Date: 22-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function businessUpdate(Request $data)
    {

        try {
            $validator = Validator::make($data->toArray(), []);

            if (!$validator->fails()) {

                $data['updated_by'] = auth()->id();

                CmnBusinessHour::where('id', $data->id)->update($data->toArray());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function getBranchWiseBusinessHour(Request $data)
    {
        try {
            $data = CmnBusinessHour::where('cmn_branch_id','=',$data->branchId)->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }

    }


}
