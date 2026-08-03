<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use App\Models\Settings\CmnBusinessHoliday;
use App\Models\Settings\CmnBusinessHour;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BusinessHolidayController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function businessHoliday()
    {
        return view('settings.business-holiday');
    }

    public function saveOrUpdateBusinessHoliday(Request $data)
    {

        try {
            $insertedId = $data->id;
            if ($insertedId == "wh")
                return $this->apiResponse(['status' => '505', 'data' => 'You are not allow to update.'], 400);

            $validator = Validator::make($data->toArray(), [
                'cmn_branch_id' => ['required', 'int'],
                'title' => ['required', 'string', 'max:200'],
                'start_date' => ['required', 'date'],
                'end_date' => ['required', 'date'],
            ]);

            if (!$validator->fails()) {
                $data['id'] = ($data->id == "" ? null : $data->id);
                if ($data->id == null) {
                    $data['created_by'] = auth()->id();
                    $resp = CmnBusinessHoliday::create($data->all());
                    $insertedId = $resp->id;
                } else {
                    $data['updated_by'] = auth()->id();
                    CmnBusinessHoliday::where('id', $data->id)->update($data->all());
                }

                $rtr = CmnBusinessHoliday::where('id', $insertedId)->select('id', 'title', 'start_date', 'end_date')->first();
                return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function updateBusinessHolidayByMove(Request $data)
    {
        try {
            $insertedId = $data->id;
            if ($insertedId == "wh")
                return $this->apiResponse(['status' => '505', 'data' => 'You are not allow to update.'], 400);

            $validator = Validator::make($data->toArray(), [
                'title' => ['required', 'string', 'max:200'],
                'start_date' => ['required', 'date'],
                'end_date' => ['required', 'date'],
            ]);

            if (!$validator->fails()) {
                $offday = CmnBusinessHoliday::where('id', $data->id)->first();
                $offday->start_date = $data->start_date;
                $offday->end_date = $data->end_date;
                $offday->updated_by = auth()->id();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function getBusinessHoliday(Request $data)
    {
        try {
            //employee offday
            $start_date = $data->year . '-01-01';
            $end_date = $data->year . '-12-31';
            $businessHoliday = CmnBusinessHoliday::where('cmn_branch_id', $data->cmn_branch_id)
                ->where('start_date', '<=', $end_date)->where('end_date', '>=', $start_date)
                ->selectRaw(
                    "id,
                start_date as start,
                end_date as end,
                title"
                )->get();

            //get business hour
            $businessHours = CmnBusinessHour::where('is_off_day', 1)->where('cmn_branch_id', $data->cmn_branch_id)->select('day')->get();

            $weeklyHoliday = array();
            while (strtotime($start_date) <= strtotime($end_date)) {
                $timestamp = strtotime($start_date);
                $day = date('w', $timestamp);
                foreach ($businessHours as $val) {
                    if ($day == $val['day']) {
                        $weeklyHoliday[] = [
                            'id' => 'wh',
                            "title" => "Weekly Holiday",
                            "start" => $start_date,
                            "end" => $start_date
                        ];
                    }
                }
                $start_date = date("Y-m-d", strtotime("+1 days", strtotime($start_date)));
            }

            return $this->apiResponse([
                'status' => '1',
                'data' =>
                [
                    'businessHoliday' => $businessHoliday,
                    'weeklyHoliday' => $weeklyHoliday
                ]
            ], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function deleteBusinessHoliday(Request $data)
    {
        try {
            if ($data->id != null) {
                CmnBusinessHoliday::where('id', $data->id)->delete();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '0', 'data' => ''], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
}
