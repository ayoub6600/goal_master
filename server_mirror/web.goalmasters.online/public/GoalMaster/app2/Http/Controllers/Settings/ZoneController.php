<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use App\Models\Zone;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ZoneController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function zone()
    {
        return view('settings.zone');
    }

    /**
     * Summary of saveCompany
     * Date: 22-Aug-2021
     * @param Request $data
     * @return JsonResponse
     */
    public function zoneStore(Request $data): JsonResponse
	{
        try {
            $validator = Validator::make($data->all(), [
                'name' => ['required', 'string', 'max:300'],
            ]);

            if (!$validator->fails()) {
            	
                Zone::query()->create($validator->validated());
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
     * @return JsonResponse
     */
    public function updateZone(Request $data): JsonResponse
	{
        try {
            $validator = Validator::make($data->all(), [
                'name' => ['required', 'string', 'max:300'],
            ]);

            if (!$validator->fails()) {
                Zone::query()->where('id', $data->id)->update($validator->validated());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
    
    /**
     * Summary of delete Zone
     * Date: 8-Aug-2021
     * @param Request $data
     * @return JsonResponse
     */
    public function deleteZone(Request $data): JsonResponse
	{
        try {

            $rtr = Zone::query()->where('id', $data->id)->delete();
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
    
    public function zoneGet(): JsonResponse
	{
  
		try {
			$data = Zone::query()->select('id', 'name')->get();
			return $this->apiResponse(['status' => '1', 'data' => $data], 200);
		} catch (Exception $qx) {
			return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
		}
    }
    
    public function getZoneList(): JsonResponse
	{
        try {
            $data = Zone::query()->select('id', 'name')->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
