<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    public function getNotifications(){
        try{
            $user = Auth::guard('api')->user();
            $notifications = $user->notifications()->paginate(10);
            return response()->json(['status' => 'true', 'data' => $notifications], 200);
        }catch(\Exception $ex){
            return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 500);
        }
    }

    public function markAsRead(Request $request){
       try{
           $user = Auth::guard('api')->user();
           $user->unreadNotifications->markAsRead();
           return response()->json(['status' => 'true', 'message' => __('apiValidation.All notifications marked as read')], 200);
        }catch(\Exception $ex){
                return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 500);
        }
    }

    public function markAsReadById(Request $request, $id)
    {
        try {
            $user = Auth::guard('api')->user();
            $notification = $user->notifications()->findOrFail($id);
    
            $notification->markAsRead();
    
            return response()->json(['status' => 'true', 'message' => __('apiValidation.Notification marked as read')], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['status' => 'false', 'message' => __('apiValidation.Notification not found')], 404);
        } catch (\Exception $ex) {
            return response()->json(['status' => 'false', 'message' => $ex->getMessage()], 500);
        }
    }
    
}
