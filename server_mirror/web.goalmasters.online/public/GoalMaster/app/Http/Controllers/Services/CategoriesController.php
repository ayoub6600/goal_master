<?php

namespace App\Http\Controllers\Services;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\Services\SchServiceCategory;
use App\Models\User;
use App\Models\UserManagement\SecUserBranch;
use App\Models\Settings\CmnBranch;
use Exception;
use Illuminate\Queue\QueueManager;
use Illuminate\Validation\Rule;

class CategoriesController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function category()
    {
        return view('services.category');
    }
    /**
     * Summary of create department
     * Author: kaysar
     * Date: 08-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function createCategory(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:200',  
                    Rule::unique('sch_service_categories')->where(function ($query) use ($data) {
                        return $query->where('cmn_branch_id', $data['cmn_branch_id']);
                    }),
                ],
                'cmn_branch_id' => ['required'],

            ]);

            if (!$validator->fails()) {
                $data['created_by'] = auth()->id();

                SchServiceCategory::create($data->all());
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
    public function updateCategory(Request $data)
    {
        try {
            $validator = Validator::make($data->toArray(), [
                'name' => ['required', 'string', 'max:200'],
            ]);
            if (!$validator->fails()) {
                SchServiceCategory::where('id', $data->id)->update([
                    'name' => $data->name,
                    'created_by' => $data->created_by,
                    'modified_by' => $data->modified_by,
                    'cmn_branch_id' => $data->cmn_branch_id,
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
    public function deleteCategory(Request $data)
    {
        try {

            $rtr = SchServiceCategory::where('id', $data->id)->delete();
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
    public function getCategorytList()
    {
        $isAllBranch = true;
        if (Auth()->id())
        {

            $user = User:: where('id', Auth()->id())->first();
            $userType =$user->user_type;
            if (!($user->is_sys_adm || $userType  == 2)) {
                $isAllBranch = false;

            }

        }

        if ($isAllBranch) {
            try {
                $data = SchServiceCategory::leftJoin('sch_services', 'sch_service_categories.id', '=', 'sch_services.sch_service_category_id')
                ->leftJoin('cmn_branches', 'sch_service_categories.cmn_branch_id', '=', 'cmn_branches.id')    
                ->selectRaw('sch_service_categories.id,
                 cmn_branches.name as branchName,
                 sch_service_categories.name,
                 count(sch_services.id) as total_service')
                    ->groupBy(
                        'sch_service_categories.id',
                        'sch_service_categories.name',
                        'cmn_branches.name',
                    )->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (QueueManager $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }
        }
        else
        {
            $userBranch = SecUserBranch::where('user_id', Auth()->id())->select('cmn_branch_id')->get();

            try {
                $data = SchServiceCategory::leftJoin('sch_services', 'sch_service_categories.id', '=', 'sch_services.sch_service_category_id')
                ->leftJoin('cmn_branches', 'sch_service_categories.cmn_branch_id', '=', 'cmn_branches.id')
                    ->selectRaw('sch_service_categories.id,
                    cmn_branches.name as branchName,
                    sch_service_categories.cmn_branch_id,
                 sch_service_categories.name,
                 count(sch_services.id) as total_service')
                    ->whereIn('sch_service_categories.cmn_branch_id', $userBranch->pluck('cmn_branch_id'))
                    ->groupBy(
                        'sch_service_categories.cmn_branch_id',
                        'sch_service_categories.id',
                        'sch_service_categories.name',
                        'cmn_branches.name'
                    )->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (QueueManager $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }
        }
    }
}
