<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\User;
use App\Models\Settings\CmnBranch;
use App\Models\UserManagement\SecUserBranch;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BranchController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function branch()
    {
        return view('settings.branch');
    }

    /**
     * Summary of saveCompany
     * Date: 22-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function branchStore(Request $data)
    {
        try {
            $validator = Validator::make($data->all(), [
                'name' => ['required', 'string', 'max:300'],
                'phone' => ['required', 'max:20'],
                'email' => ['required', 'email', 'unique:cmn_branches'],
                'address' => ['required', 'string', 'max:300']
            ]);

            if (!$validator->fails()) {

                $data['created_by'] = auth()->id();
                $data['order'] =UtilityRepository::emptyOrNullToZero($data->order);
                CmnBranch::create($data->toArray());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    /**
     * Summary of updateCompany
     * Date: 22-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateBranch(Request $data)
    {
        try {
            $validator = Validator::make($data->all(), [
                'name' => ['required', 'string', 'max:300'],
                'phone' => ['required', 'max:20'],
                'email' => ['required', 'email',],
                'address' => ['required', 'string', 'max:300'],
                'lat' => ['required', 'string'],
                'long' => ['required', 'string'],
                'zone_id' => ['required', 'integer']
            ]);

            if (!$validator->fails()) {
                $data['updated_by'] =auth()->id();
                $data['order'] = UtilityRepository::emptyOrNullToZero($data->order);
                CmnBranch::where('id', $data->id)->update($data->toArray());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }



    /**
     * Summary of delete Branch
     * Date: 8-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteBranch(Request $data)
    {
        try {

            $rtr = CmnBranch::where('id', $data->id)->delete();
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }



    public function branchGet()
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
                $data = CmnBranch::with('zone')->
				select(
                    'id',
                    'name',
                    'phone',
                    'email',
                    'address',
                    'order',
                    'lat',
                    'long',
                    'zone_id',
                    'status',
                    'created_by',
                    'updated_by'
                )
					->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (Exception $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }
        }

        else
        {
        $userBranch = SecUserBranch::where('user_id', Auth()->id())->select('cmn_branch_id')->get();

            try {
                $data = CmnBranch::with('zone')->select(
                    'id',
                    'name',
                    'phone',
                    'email',
                    'address',
                    'order',
					'lat',
					'long',
					'zone_id',
                    'status',
                    'created_by',
                    'updated_by'
                ) ->whereIn('id', $userBranch->pluck('cmn_branch_id'))
                ->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (Exception $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }

        }
    }


    public function getBranchList()
    {
        try {
            $data = CmnBranch::select('id', 'name', 'order')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
