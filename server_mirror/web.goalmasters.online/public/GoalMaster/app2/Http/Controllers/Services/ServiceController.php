<?php

namespace App\Http\Controllers\Services;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Services\SchServices;
use App\Models\User;
use App\Models\UserManagement\SecUserBranch;
use App\Models\Settings\CmnBranch;
use Illuminate\Http\Request;
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
                // 'durationTimeMinute' => ['required'],
                'sch_service_category_id' => ['required'],
                'minimum_time_required_to_booking_in_minute' => ['required'],
                'minimum_time_required_to_cancel_in_minute' => ['required'],
                'serviceimage' => 'image|mimes:jpeg,png,jpg,gif|max:512|required',
            ]);

            if (!$validator->fails()) {
                $serviceImage = $data->serviceimage;
                if ($serviceImage != null) {
                    $serviceImage = UtilityRepository::saveFile($serviceImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                    $data['image'] = $serviceImage;
                }

                // $paddingTimeB = $data->padding_time_before_hour . ':' . $data->padding_time_before_minute;
                // $paddingTimeA = $data->padding_time_after_hour . ':' . $data->padding_time_after_minute;

                // $duration_in_time = $data->durationTimeHour . ':' . $data->durationTimeMinute;
                $minimum_time_required_to_booking_in_time = $data->minimum_time_required_to_booking_in_hour . ':' . $data->minimum_time_required_to_booking_in_minute;
                $minimum_time_required_to_cancel_in_time = $data->minimum_time_required_to_cancel_in_hour . ':' . $data->minimum_time_required_to_cancel_in_minute;

                $time_slot_in_time = $data->time_slot_in_time_hour . ':' . $data->time_slot_in_time_minute;


                // $data['duration_in_time'] = $duration_in_time;
                // $data['padding_time_before'] = $paddingTimeB;
                // $data['padding_time_after'] = $paddingTimeA;
                $data['time_slot_in_time'] = $time_slot_in_time;
                $data['minimum_time_required_to_booking_in_time'] = $minimum_time_required_to_booking_in_time;
                $data['minimum_time_required_to_cancel_in_time'] = $minimum_time_required_to_cancel_in_time;
                $data['id']=null;
                SchServices::create($data->all());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        }catch (Exception $ex) {
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
    public function serviceUpdate(Request $data)
    {
        try {

            $validator = Validator::make($data->toArray(), [
                'title' => ['required', 'string'],
                'serviceimage' => 'image|mimes:jpeg,png,jpg,gif|max:512',
                // 'durationTimeMinute' => ['required'],
                'sch_service_category_id' => ['required'],
                'minimum_time_required_to_booking_in_minute' => ['required'],
                'minimum_time_required_to_cancel_in_minute' => ['required'],
            ]);

            if (!$validator->fails()) {
                // $paddingTimeBefore = $data->padding_time_before_hour . ':' . $data->padding_time_before_minute;
                // $paddingTimeAfter = $data->padding_time_after_hour . ':' . $data->padding_time_after_minute;

                // $durationTimeHour = $data->durationTimeHour . ':' . $data->durationTimeMinute;
                $minimum_time_required_to_booking_in_time = $data->minimum_time_required_to_booking_in_hour . ':' . $data->minimum_time_required_to_booking_in_minute;
                $minimum_time_required_to_cancel_in_time = $data->minimum_time_required_to_cancel_in_hour . ':' . $data->minimum_time_required_to_cancel_in_minute;

                $time_slot_in_time = $data->time_slot_in_time_hour . ':' . $data->time_slot_in_time_minute;

                $imagePath = $data->serviceimage;
                if ($imagePath != null) {
                    $imagePath = UtilityRepository::saveFile($imagePath, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                }

                $dataForUpdate = [
                    'title' => $data->title,
                    'sch_service_category_id' => $data->sch_service_category_id,
                    'visibility' => $data->visibility,
                    'price' => $data->price,
                    // 'duration_in_days' => $data->duration_in_days,
                    // 'duration_in_time' => $durationTimeHour,
                    'time_slot_in_time' => $time_slot_in_time,
                    // 'padding_time_before' => $paddingTimeBefore,
                    // 'padding_time_after' => $paddingTimeAfter,
                    // 'appoinntment_limit_type' => $data->appoinntment_limit_type,
                    // 'appoinntment_limit' => $data->appoinntment_limit,
                    'minimum_time_required_to_booking_in_days' => $data->minimum_time_required_to_booking_in_days,
                    'minimum_time_required_to_booking_in_time' => $minimum_time_required_to_booking_in_time,
                    'minimum_time_required_to_cancel_in_days' => $data->minimum_time_required_to_cancel_in_days,
                    'minimum_time_required_to_cancel_in_time' => $minimum_time_required_to_cancel_in_time,
                    'remarks'=>$data->remarks
                ];
                if ($imagePath != null || $imagePath != '')
                    $dataForUpdate['image'] = $imagePath;

                SchServices::where('id', $data->id)->update($dataForUpdate);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }

            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        }catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
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
                $data = SchServices::join('sch_service_categories', 'sch_services.sch_service_category_id', '=', 'sch_service_categories.id')
                    ->select(
                        'sch_service_categories.name as category',
                        'sch_services.id',
                        'sch_services.title',
                        'sch_services.image',
                        'sch_services.sch_service_category_id',
                        'sch_services.visibility',
                        'sch_services.price',
                        'sch_services.duration_in_days',
                        'sch_services.duration_in_time',
                        'sch_services.time_slot_in_time',
                        'sch_services.padding_time_before',
                        'sch_services.padding_time_after',
                        'sch_services.appoinntment_limit_type',
                        'sch_services.appoinntment_limit',
                        'sch_services.minimum_time_required_to_booking_in_days',
                        'sch_services.minimum_time_required_to_booking_in_time',
                        'sch_services.minimum_time_required_to_cancel_in_days',
                        'sch_services.minimum_time_required_to_cancel_in_time',
                        'sch_services.remarks'
                    )->orderByRaw('sch_services.created_at desc')->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (Exception $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }
        }

        else
        {
            try {
              $userBranch = SecUserBranch::where('user_id', Auth()->id())->select('cmn_branch_id')->get();
          
              $data = SchServices::join('sch_service_categories', 'sch_services.sch_service_category_id', '=', 'sch_service_categories.id')
                  ->select(
                      'sch_service_categories.cmn_branch_id',
                      'sch_service_categories.name as category',
                      'sch_services.id',
                      'sch_services.title',
                      'sch_services.image',
                      'sch_services.sch_service_category_id',
                      'sch_services.visibility',
                      'sch_services.price',
                      'sch_services.duration_in_days',
                      'sch_services.duration_in_time',
                      'sch_services.time_slot_in_time',
                      'sch_services.padding_time_before',
                      'sch_services.padding_time_after',
                      'sch_services.appoinntment_limit_type',
                      'sch_services.appoinntment_limit',
                      'sch_services.minimum_time_required_to_booking_in_days',
                      'sch_services.minimum_time_required_to_booking_in_time',
                      'sch_services.minimum_time_required_to_cancel_in_days',
                      'sch_services.minimum_time_required_to_cancel_in_time',
                      'sch_services.remarks'
                  )
                  ->whereIn('sch_service_categories.cmn_branch_id', $userBranch->pluck('cmn_branch_id'))
          
                  ->orderByRaw('sch_services.created_at desc')->get();
              return $this->apiResponse(['status' => '1', 'data' => $data], 200);
          } catch (Exception $qx) {
              return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
          }
            
        }

    }
}
