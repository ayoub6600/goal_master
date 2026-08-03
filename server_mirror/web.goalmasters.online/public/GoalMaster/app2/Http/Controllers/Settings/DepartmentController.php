<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Settings\HrmDepartment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class DepartmentController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function department()
    {
        return view('settings.department');
    }

    /**
     * Summary of create department
     * Author: kaysar
     * Date: 08-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function createDepartment(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:200', 'unique:hrm_departments'],
            ]);

            if (!$validator->fails()) {
                $data['created_by'] = auth()->id();
                $data['order'] =UtilityRepository::emptyOrNullToZero($data->order);

                HrmDepartment::create($data->all());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Summary of update department
     * Author: kaysar
     * Date: 08-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateDepartment(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:200'],
            ]);
            if (!$validator->fails()) {
                HrmDepartment::where('id', $data->id)->update([
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
     * Summary of delete Department
     * Author: Kaysar
     * Date: 8-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteDepartment(Request $data)
    {
        try {

            $rtr = HrmDepartment::where('id', $data->id)->delete();
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
    public function getDepartmentList()
    {
        try {
            $data = HrmDepartment::leftJoin('sch_employees', 'hrm_departments.id', '=', 'sch_employees.hrm_department_id')
                ->selectRaw(
                    'hrm_departments.id,
                    hrm_departments.name,
                    hrm_departments.order,
                    count(sch_employees.id) as total_employee'
                )->groupBy(
                    'hrm_departments.id',
                    'hrm_departments.name',
                    'hrm_departments.order'
                )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
