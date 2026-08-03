<?php

namespace App\Http\Controllers\Services;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Services\SchServices;
use App\Models\User;
use App\Models\UserManagement\SecUserBranch;
use App\Models\Settings\CmnBranch;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use ErrorException;
use Exception;


class ServiceController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function service()
    {
        return view('services.service');
    }


    /**
     * Summary of create department
     * Author: kaysar
     * Date: 08-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function serviceStore(Request $data)
    {
        try {
            $validator = Validator::make($data->all(), [
                'title' => ['required', 'string'],
                'price' => ['required'],
                'sch_service_category_id' => ['required'],
                'minimum_time_required_to_booking_in_minute' => ['required'],
                'minimum_time_required_to_cancel_in_minute' => ['required'],
                'serviceimage' => 'required|image|mimes:jpeg,png,jpg,gif|max:512',
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
            }

            // Compose time fields
            $minimum_time_required_to_booking_in_time = $data->minimum_time_required_to_booking_in_hour . ':' . $data->minimum_time_required_to_booking_in_minute;
            $minimum_time_required_to_cancel_in_time = $data->minimum_time_required_to_cancel_in_hour . ':' . $data->minimum_time_required_to_cancel_in_minute;
            $time_slot_in_time = $data->time_slot_in_time_hour . ':' . $data->time_slot_in_time_minute;

            $dataToCreate = [
                'title' => $data->title,
                'price' => $data->price,
                'sch_service_category_id' => $data->sch_service_category_id,
                'minimum_time_required_to_booking_in_minute' => $data->minimum_time_required_to_booking_in_minute,
                'minimum_time_required_to_cancel_in_minute' => $data->minimum_time_required_to_cancel_in_minute,
                'time_slot_in_time' => $time_slot_in_time,
                'minimum_time_required_to_booking_in_time' => $minimum_time_required_to_booking_in_time,
                'minimum_time_required_to_cancel_in_time' => $minimum_time_required_to_cancel_in_time,
                // add other needed fields here if any
            ];

            $service = SchServices::create($dataToCreate);

            // Save image using Spatie Media Library
            if ($data->hasFile('serviceimage')) {
                $service->addMediaFromRequest('serviceimage')
                    ->usingFileName(uniqid() . '.' . $data->file('serviceimage')->getClientOriginalExtension())
                    ->toMediaCollection('services');
            }

            return $this->apiResponse(['status' => '1', 'data' => $service], 200);

        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex->getMessage()], 400);
        }
    }

    /**
     * Summary of update department
     * Author: kaysar
     * Date: 08-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function serviceUpdate(Request $data)
    {

        try {
            $validator = Validator::make($data->toArray(), [
                'id' => ['required', 'exists:sch_services,id'],
                'title' => ['required', 'string'],
                'serviceimage' => 'image|mimes:jpeg,png,jpg,gif|max:512',
                'sch_service_category_id' => ['required'],
                'minimum_time_required_to_booking_in_minute' => ['required'],
                'minimum_time_required_to_cancel_in_minute' => ['required'],
            ]);

            if ($validator->fails()) {
                return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
            }

            $service = SchServices::findOrFail($data->id);

            $minimum_time_required_to_booking_in_time = $data->minimum_time_required_to_booking_in_hour . ':' . $data->minimum_time_required_to_booking_in_minute;
            $minimum_time_required_to_cancel_in_time = $data->minimum_time_required_to_cancel_in_hour . ':' . $data->minimum_time_required_to_cancel_in_minute;
            $time_slot_in_time = $data->time_slot_in_time_hour . ':' . $data->time_slot_in_time_minute;

            $dataForUpdate = [
                'title' => $data->title,
                'sch_service_category_id' => $data->sch_service_category_id,
                'visibility' => $data->visibility ?? $service->visibility,
                'price' => $data->price,
                'time_slot_in_time' => $time_slot_in_time,
                'minimum_time_required_to_booking_in_days' => $data->minimum_time_required_to_booking_in_days ?? $service->minimum_time_required_to_booking_in_days,
                'minimum_time_required_to_booking_in_time' => $minimum_time_required_to_booking_in_time,
                'minimum_time_required_to_cancel_in_days' => $data->minimum_time_required_to_cancel_in_days ?? $service->minimum_time_required_to_cancel_in_days,
                'minimum_time_required_to_cancel_in_time' => $minimum_time_required_to_cancel_in_time,
                'remarks' => $data->remarks ?? $service->remarks,
            ];

            // Update service fields first
            $service->update($dataForUpdate);

            // If there is a new image, replace old one
            if ($data->hasFile('serviceimage')) {
                // Remove old media in 'services' collection
                $service->clearMediaCollection('services');

                // Add new image
                $service->addMediaFromRequest('serviceimage')
                    ->usingFileName(uniqid() . '.' . $data->file('serviceimage')->getClientOriginalExtension())
                    ->toMediaCollection('services');
            }

            return $this->apiResponse(['status' => '1', 'data' => $service], 200);

        } catch (ErrorException $ex) {
            return $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex->getMessage()], 400);
        }
    }


    /**
     * Summary of delete Department
     * Author: Kaysar
     * Date: 8-Aug-2021
     * @param Request $data
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteService(Request $data)
    {
        try {
            $rtr = SchServices::where('id', $data->id)->delete();
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
    public function getServiceList()
    {
        try {
            $user = Auth::user();
            // Determine if user can see all branches (sys admin or user_type 2)
            $isAllBranch = $user ? ($user->is_sys_adm || $user->user_type == 2) : true;

            $baseQuery = SchServices::with(['category' => function($query) {
                $query->select('id', 'name', 'cmn_branch_id');
            }])
                ->select([
                    'id',
                    'title',
                    'sch_service_category_id',
                    'visibility',
                    'price',
                    'duration_in_days',
                    'duration_in_time',
                    'time_slot_in_time',
                    'padding_time_before',
                    'padding_time_after',
                    'appoinntment_limit_type',
                    'appoinntment_limit',
                    'minimum_time_required_to_booking_in_days',
                    'minimum_time_required_to_booking_in_time',
                    'minimum_time_required_to_cancel_in_days',
                    'minimum_time_required_to_cancel_in_time',
                    'remarks',
                    'created_at'
                ]);

            if (!$isAllBranch && $user) {
                // Get user's branch IDs
                $branchIds = SecUserBranch::where('user_id', $user->id)
                    ->pluck('cmn_branch_id')
                    ->toArray();

                // Filter services by category branches
                $baseQuery->whereHas('category', function($query) use ($branchIds) {
                    $query->whereIn('cmn_branch_id', $branchIds);
                });
            }

            $services = $baseQuery->latest('created_at')->get();

            $data = $services->map(function ($service) {
                return [
                    'id' => $service->id,
                    'category' => $service->category->name ?? '',
                    'title' => $service->title,
                    'image_url' => $service->getFirstMediaUrl('services') ?: null,
                    'sch_service_category_id' => $service->sch_service_category_id,
                    'visibility' => $service->visibility,
                    'price' => $service->price,
                    'duration_in_days' => $service->duration_in_days,
                    'duration_in_time' => $service->duration_in_time,
                    'time_slot_in_time' => $service->time_slot_in_time,
                    'padding_time_before' => $service->padding_time_before,
                    'padding_time_after' => $service->padding_time_after,
                    'appoinntment_limit_type' => $service->appoinntment_limit_type,
                    'appoinntment_limit' => $service->appoinntment_limit,
                    'minimum_time_required_to_booking_in_days' => $service->minimum_time_required_to_booking_in_days,
                    'minimum_time_required_to_booking_in_time' => $service->minimum_time_required_to_booking_in_time,
                    'minimum_time_required_to_cancel_in_days' => $service->minimum_time_required_to_cancel_in_days,
                    'minimum_time_required_to_cancel_in_time' => $service->minimum_time_required_to_cancel_in_time,
                    'remarks' => $service->remarks,
                    'branch_id' => $service->category->cmn_branch_id ?? null,
                ];
            });

            return $this->apiResponse([
                'status' => 'success',
                'data' => $data
            ], 200);

        } catch (Exception $e) {
            Log::error('Service List Error: ' . $e->getMessage());
            return $this->apiResponse([
                'status' => 'error',
                'message' => __('Failed to retrieve service list')
            ], 500);
        }
    }
}
