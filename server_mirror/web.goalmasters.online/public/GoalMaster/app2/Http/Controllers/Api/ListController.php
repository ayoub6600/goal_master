<?php

namespace App\Http\Controllers\Api;

use App\Http\Resources\SlidersResource;
use App\Models\Slide;
use Exception;
use Carbon\Carbon;
use App\Models\Zone;
use App\Enums\ServiceStatus;
use Illuminate\Http\Request;
use App\Models\Settings\CmnZone;
use App\Http\Requests\ZoneRequest;
use App\Models\Settings\CmnBranch;
use App\Http\Controllers\Controller;
use App\Models\Customer\CmnCustomer;
use App\Models\Employee\SchEmployee;
use App\Models\Services\SchServices;
use App\Http\Requests\ServiceRequest;
use App\Http\Requests\BookListRequest;
use App\Http\Requests\CategoryRequest;
use App\Models\Settings\CmnBusinessHour;
use App\Models\Employee\SchEmployeeOffday;
use App\Http\Repository\DateTimeRepository;
use App\Models\Employee\SchEmployeeService;
use App\Models\Services\SchServiceCategory;
use App\Models\Settings\CmnBusinessHoliday;
use App\Models\Employee\SchEmployeeSchedule;
use App\Http\Repository\Booking\BookingRepository;
use PhpOffice\PhpSpreadsheet\Calculation\Web\Service;

class ListController extends Controller
{
    public function getZonelist()
    {
       try{
         $zones = Zone::all();
         return response()->json(['status' => 'true', 'data' => $zones], 200);
       }catch(\Exception $e){
           return response()->json(['status' => 'false', 'message' => $e->getMessage()], 500);
      }
    }

    public function getClubList(ZoneRequest $request)
    {
        try{
            $validated = $request->validated();
            $zone_id = $validated['zone'] ?? null;
            $clubs = CmnBranch::query()
                ->when($zone_id, function ($query) use ($zone_id) {
                    $query->where('zone_id', $zone_id);
                })->get();
            return response()->json(['status' => 'true', 'data' => $clubs], 200);
        }catch(\Exception $e){
            return response()->json(['status' => 'false', 'message' => $e->getMessage()], 500);
        }
    }

    public function getCategoryList(CategoryRequest $request)
    {
        try{
            $validated = $request->validated();
            $branch_id = $validated['branch'] ?? null;
            $category = SchServiceCategory::query()
                ->when($branch_id, function ($query) use ($branch_id) {
                    $query->where('cmn_branch_id', $branch_id);
                })
                ->with('CmnBranch')->get();
            return response()->json(['status' => 'true', 'data' => $category], 200);
        }catch(\Exception $e){
            return response()->json(['status' => 'false', 'message' => $e->getMessage()], 500);
        }
    }


    public function getServiceList(ServiceRequest $request)
    {
        try {
            $validated = $request->validated();
            $category_id = $validated['category'] ?? null;
            $branch_id = $validated['branch'] ?? null;

            $services = SchServices::query()
                ->when($category_id, function ($query) use ($category_id) {
                    $query->where('sch_service_category_id', $category_id);
                })
                ->when($branch_id, function ($query) use ($branch_id) {
                    $query->whereHas('category', function ($q) use ($branch_id) {
                        $q->where('cmn_branch_id', $branch_id);
                    });
                })
                ->get();

            return response()->json(['status' => 'true', 'data' => $services], 200);
        } catch (\Exception $e) {
            return response()->json(['status' => 'false', 'message' => $e->getMessage()], 500);
        }
    }

    public function getBookingList(CategoryRequest $request)
    {
        try {
            $validated = $request->validated();
            $branch_id = $validated['branch'] ?? null;
            $sch_employees = SchEmployee::query()
                ->where('cmn_branch_id', $branch_id)
                ->with('designation' ,'branch')
                ->get()
                ->unique('full_name')
                ->values();
                return response()->json(['status' => 'true', 'data' => $sch_employees], 200);
        }catch(\Exception $e){
              return response()->json(['status' => 'false', 'message' => $e->getMessage()], 500);
        }
    }


 public function customersList()
 {
    try{
        $customers = CmnCustomer::paginate(10);
        ;
        $customers->getCollection()->transform(function ($customer) {
            return [
                'id' => $customer->id,
                'full_name' => $customer->full_name,
                'phone_no' => $customer->phone_no,
                'phone_verified' => $customer->is_phone_verified,
            ];
        });

        return response()->json(['status' => 'true', 'data' => $customers], 200);
    }catch(Exception $ex){
        return response()->json(['status'=>'false','massage'=>$ex->getMessage()], 500);
    }
 }

 public function serviceStatusList()
 {
    try {
        $statuses = ServiceStatus::asArray();

        $formattedStatuses = collect($statuses)->map(function ($value, $key) {
            return [
                'id' => $value,
                'name_en' => $key,
                'name_ar' => __(ServiceStatus::getDescription($value)),
            ];
        })->values();

        return response()->json(['status' => 'true', 'data' => $formattedStatuses], 200);
    } catch (Exception $ex) {
        return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 500);
    }
   }

   //getSlider
     public function getSlider()
    {
        
              $sliders = Slide::where('status', 'active')->latest()->get();
                return response()->json(['status' => 'true', 'data' => SlidersResource::collection($sliders)], 200);
           

    }

 }


