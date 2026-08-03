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
                'address' => ['required', 'string', 'max:300'],
                'image' => ['nullable', 'image', 'max:2048'], // Optional image
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
            }

            $data['created_by'] = auth()->id();
            $data['order'] = UtilityRepository::emptyOrNullToZero($data->order);

            // exclude 'image' from mass assignment
            $input = $data->except(['image']);
            $branch = CmnBranch::create($input);

            // save image if available
            if ($data->hasFile('image')) {
                $branch->addMedia($data->file('image'))->toMediaCollection('cmn_branch');
            }

            return $this->apiResponse(['status' => '1', 'data' => ''], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex->getMessage()], 400);
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
                'email' => ['required', 'email'],
                'address' => ['required', 'string', 'max:300'],
                'lat' => ['required', 'string'],
                'long' => ['required', 'string'],
                'zone_id' => ['required', 'integer'],
                'image' => ['nullable', 'image', 'max:2048'], // Optional image upload
            ]);

            if (!$validator->fails()) {
                $branch = CmnBranch::findOrFail($data->id);

                $data['updated_by'] = auth()->id();
                $data['order'] = UtilityRepository::emptyOrNullToZero($data->order);

                // Update branch data except image
                $branch->update($data->except('image'));

                // If image is uploaded, replace old image with new one
                if ($data->hasFile('image')) {
                    $branch->clearMediaCollection('cmn_branch');
                    $branch->addMedia($data->file('image'))->toMediaCollection('cmn_branch');
                }

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
        $authId = auth()->id();

        if ($authId) {
            $user = User::find($authId);
            if (!($user->is_sys_adm || $user->user_type == 2)) {
                $isAllBranch = false;
            }
        }

        try {
            $query = CmnBranch::with('zone')
                ->select(
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
                );

            if (!$isAllBranch) {
                $userBranchIds = SecUserBranch::where('user_id', $authId)
                    ->pluck('cmn_branch_id')
                    ->toArray();
                $query->whereIn('id', $userBranchIds);
            }

            $data = $query->get()->map(function($branch) {
                return [
                    'id' => $branch->id,
                    'name' => $branch->name,
                    'phone' => $branch->phone,
                    'email' => $branch->email,
                    'address' => $branch->address,
                    'order' => $branch->order,
                    'lat' => $branch->lat,
                    'long' => $branch->long,
                    'zone_id' => $branch->zone_id,
                    'zone' => $branch->zone,
                    'status' => $branch->status,
                    'created_by' => $branch->created_by,
                    'updated_by' => $branch->updated_by,
                    'image_url' => $branch->getFirstMediaUrl('cmn_branch') ?: asset('img/ball.png'),
                ];
            });

            return $this->apiResponse([
                'status' => '1',
                'data' => $data
            ], 200);

        } catch (Exception $e) {
            return $this->apiResponse([
                'status' => 'error',
                'message' => __('Failed to retrieve branches'),
                'error' => $e->getMessage()
            ], 500);
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
