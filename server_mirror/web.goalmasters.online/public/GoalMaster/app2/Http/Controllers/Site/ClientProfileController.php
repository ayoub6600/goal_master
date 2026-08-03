<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Customer\CmnCustomer;
use App\Models\User;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ClientProfileController extends Controller
{
    public function clientProfile()
    {
        return view('site.client.client-profile');
    }

    public function getUserBasicInfo()
    {
        try {
            $user = $user = User::where('id', auth()->id())
                ->select(
                    'name',
                    'username',
                    // 'email',
                    'phone_number',
                    'photo'
                )->first();

            $customer = CmnCustomer::where('user_id', auth()->id())->first();
            return $this->apiResponse(['status' => '1', 'data' => ['user' => $user, 'customer' => $customer]], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '403', 'data' => $ex], 400);
        }
    }

    public function saveClientProfile(Request $request)
    {
        DB::beginTransaction();
        try {
            $validator = Validator::make($request->all(), [
                'name' => ['required', 'string', 'max:50'],
                'phone_no' => ['required', 'string', 'max:20'],
                'street_address' => ['required', 'string', 'max:500'],
                'user_photo' => 'image|mimes:jpeg,png,jpg,gif|max:512',
            ]);
            if (!$validator->fails()) {
                $data = $request->toArray();
                $userPhoto = $request->user_photo;
                if ($userPhoto != null) {
                    $userPhoto = UtilityRepository::saveFile($userPhoto, ['image/png', 'image/jpg', 'image/jpeg']);
                }
                $user = User::where('id', auth()->id())->first();
                if ($user != null) {
                    $user->name = $data['name'];
                    if ($userPhoto != null)
                        $user->photo = $userPhoto;
                    $user->update();
                }

                $customer = CmnCustomer::where('user_id', auth()->id())->first();
                if ($customer != null) {
                    $customer->full_name = $data['name'];
                    $customer->phone_no = $data['phone_no'];
                    // $customer->email = $data['email'];
                    $customer->dob = $data['dob'];
                    $customer->country = $data['country'];
                    $customer->state = $data['state'];
                    $customer->postal_code = $data['postal_code'];
                    $customer->city = $data['city'];
                    $customer->street_number = $data['street_number'];
                    $customer->street_address = $data['street_address'];
                    $customer->update();
                } else {
                   CmnCustomer::create([
                        'full_name' => $data['name'],
                        'phone_no' => $data['phone_no'],
                        // 'email' => $data['email'],
                        'dob' => $data['dob'],
                        'country' => $data['country'],
                        'state' => $data['state'],
                        'postal_code' => $data['postal_code'],
                        'city' => $data['city'],
                        'street_number' => $data['street_number'],
                        'street_address' => $data['street_address'],
                        'user_id'=> auth()->id()
                    ]);
                }
                DB::commit();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }
}
