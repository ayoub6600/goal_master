<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Settings\HrmDesignation;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Queue\QueueManager;
use Illuminate\Support\Facades\Validator;

class DesignationController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth');
    }

    public function designation()
    {
        return view('settings.designation');
    }

    /**
     * Summary of create designation
     * Author: kaysar
     * Date: 08-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function designationStore(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:200', 'unique:hrm_designations'],
            ]);

            if (!$validator->fails()) {
                $data['created_by'] = auth()->id();
                $data['order'] = UtilityRepository::emptyOrNullToZero($data->order);

                HrmDesignation::create($data->all());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Summary of update designation
     * Author: kaysar
     * Date: 08-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function designationEdit(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:200'],
            ]);
            if (!$validator->fails()) {
                HrmDesignation::where('id', $data->id)->update([
                    'name' => $data->name,
                    'order' => UtilityRepository::emptyOrNullToZero($data->order),
                    'updated_by' => auth()->id()
                ]);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Summary of delete Designation
     * Author: Kaysar
     * Date: 8-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function designationDelete(Request $data)
    {
        try {

            $rtr = HrmDesignation::where('id', $data->id)->delete();
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Summary of get brandepartment list
     * Author: Kaysar
     * Date: 8-Aug-2021
     * @return \Illuminate\Http\JsonResponse
     */
    public function getDesignationList()
    {
        try {
            $data = HrmDesignation::leftJoin('sch_employees', 'hrm_designations.id', '=', 'sch_employees.hrm_designation_id')
                ->selectRaw(
                    'hrm_designations.id,
                    hrm_designations.name,
                    hrm_designations.order,
                    count(sch_employees.id) as total_employee'
                )->groupByRaw('hrm_designations.id, hrm_designations.name, hrm_designations.order')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (QueueManager $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
