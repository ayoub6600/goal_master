<?php

namespace App\Http\Controllers\Api;

use Exception;
use Carbon\Carbon;
use App\Models\Zone;
use App\Models\Slide;
use App\Enums\UserType;
use App\Enums\ServiceStatus;
use Illuminate\Http\Request;
use App\Models\Settings\CmnZone;
use App\Http\Requests\ZoneRequest;
use App\Models\Settings\CmnBranch;
use Tymon\JWTAuth\Facades\JWTAuth;
use App\Http\Controllers\Controller;
use App\Models\Customer\CmnCustomer;
use App\Models\Employee\SchEmployee;
use App\Models\Services\SchServices;
use Illuminate\Support\Facades\Auth;
use App\Http\Requests\ServiceRequest;
use App\Http\Requests\BookListRequest;
use App\Http\Requests\CategoryRequest;
use App\Http\Resources\SlidersResource;
use App\Models\Settings\CmnBusinessHour;
use App\Models\Employee\SchEmployeeOffday;
use App\Http\Repository\DateTimeRepository;
use App\Models\Employee\SchEmployeeService;
use App\Models\Services\SchServiceCategory;
use App\Models\Settings\CmnBusinessHoliday;
use App\Models\Employee\SchEmployeeSchedule;
use App\Http\Repository\Booking\BookingRepository;
use PhpOffice\PhpSpreadsheet\Calculation\Web\Service;
use App\Models\UserManagement\SecUserBranch;


class ListController extends Controller
{
  public function getZonelist()
  {
      try {
          $user = $this->getAuthenticatedUser();
          $zones = $this->getZonesForUser($user);

          return response()->json(['status' => true,'data' => $zones], 200);
      } catch (\Exception $e) {
          return response()->json(['status' => false,'message' => $e->getMessage()], 500);
      }
  }

  /**
   * Get the authenticated user from the bearer token (if valid).
   */
  private function getAuthenticatedUser()
  {
      if ($token = request()->bearerToken()) {
          try {
              return JWTAuth::setToken($token)->authenticate();
          } catch (\Exception $e) {
              // Token invalid or expired
          }
      }
      return null;
  }

  /**
   * Return zones based on the user's type.
   */
  private function getZonesForUser($user)
  {
      // If the user is an Owner, return only zones with their clubs
      if ($user && $user->user_type == UserType::SystemUser) {
          $zoneIds = CmnBranch::where('created_by', $user->id)
                         ->distinct()
                         ->pluck('zone_id');

          return Zone::whereIn('id', $zoneIds)->get();
      }

      // Otherwise, return all zones
      return Zone::all();
  }


  public function getClubList(ZoneRequest $request)
  {
        try {
            $validated = $request->validated();
            $zoneId = $validated['zone'] ?? null;

            $user = $this->getAuthenticatedUser();

            $clubs = $this->getClubsFiltered($zoneId, $user);

            $data = $clubs->map(function ($club) {
                return array_merge(
                    $club->toArray(),
                    ['image' => $club->getFirstMediaUrl('cmn_branch') ?: asset('img/ball.png')]
                );
            });

            return response()->json(['status' => true, 'data' => $data], 200);
        } catch (\Exception $e) {
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }

  
    /**
     * Filter clubs based on zone and user ownership.
     */
    private function getClubsFiltered($zoneId, $user)
    {
        return CmnBranch::query()
            ->when($zoneId, fn($query) => $query->where('zone_id', $zoneId))
            ->when($user && $user->user_type == UserType::SystemUser, fn($query) => $query->where('created_by', $user->id))
            ->get();
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
    try {
        
        $userBranch = SecUserBranch::where('user_id', auth()->id())
                        ->pluck('cmn_branch_id')
                        ->toArray();

        $customers = CmnCustomer::whereHas('serviceBookings', function($q) use ($userBranch) {
            $q->whereIn('cmn_branch_id', $userBranch);
        })->paginate(10);

        $customers->getCollection()->transform(function ($customer) {
            return [
                'id' => $customer->id,
                'full_name' => $customer->full_name,
                'phone_no' => $customer->phone_no,
                'phone_verified' => $customer->is_phone_verified,
            ];
        });

        return response()->json(['status' => 'true', 'data' => $customers], 200);
    } catch(Exception $ex) {
        return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 500);
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


