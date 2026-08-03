<?php

use Illuminate\Http\Request;
use App\Events\NotificationEvent;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ListController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Card\ChargeController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\Dashboard\UserController;
use App\Http\Controllers\Api\Booking\BookingController;
use App\Http\Controllers\Api\Dashboard\ManagerController;
use App\Http\Controllers\Api\Booking\BookingInfoController;
use App\Http\Controllers\Api\Booking\MonthlyBookingController;
/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});


Route::group(['middleware' => ['api', 'setLocale' ]], function () {
    // ? Auth
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'create']);
    Route::post('/verify', [AuthController::class, 'verifyOtp']);
    Route::post('/resend-otp', [AuthController::class, 'resendOtp']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);
    
    Route::group(['middleware' => ['jwt.auth:api'],'prefix' => "user"], function () {
            Route::get('/profile', [AuthController::class, 'profile']);
            Route::delete('/delete', [AuthController::class, 'deleteAccount']);

            Route::post('/change-password-user',[AuthController::class,'changePasswordUser']);
            // ? user info 
            Route::post('/update', [ProfileController::class, 'UpdateProfile']);
            Route::post('/refresh' ,[AuthController::class, 'refreshToken']);
            Route::post('/logout', [AuthController::class, 'logout']);
            
        // ? analysis
        Route::group(['prefix' => "analysis"], function () {
            Route::get('/', [UserController::class, 'userBookingsAnalysis']);
        });

        Route::group(['prefix' => "booking"], function () {
            Route::get('/history', [BookingController::class, 'myBookings']);
            Route::post('/fillter-new-booking', [BookingController::class, 'filterBookings']);
            Route::get('/get-forgiving-generous', [MonthlyBookingController::class, 'getForgivingGenerous']);
            Route::get('/getMonthlyBookingList', [MonthlyBookingController::class, 'getMonthlyBookingList'])->middleware('manager');
            Route::post('/updateMonthlyBooking', [MonthlyBookingController::class, 'updateMonthlyBooking'])->middleware('manager');
            Route::get('/all',[BookingController::class,'getServiceBookingInfo'])->middleware('manager');
            Route::post('/store-booking',[BookingController::class, 'saveBooking']);
            Route::post('/update-booking',[BookingController::class, 'updateBooking']);
            Route::post('/cancel-booking',[BookingController::class, 'cancelBooking']);
            Route::post('/get-info', [BookingController::class, 'getBookingInfo']);
        });

        Route::group(['prefix' => "notifications"], function () {
            Route::get('/get-notification', [NotificationController::class, 'getNotifications']);
            Route::post('/read-notification/{id}', [NotificationController::class, 'markAsReadById']);
            Route::post('/read-all-notification', [NotificationController::class, 'markAsRead']);
        });
        Route::group(['prefix' => "card"], function () {
            Route::post('/charge', [ChargeController::class, 'chargeCard']);
            Route::post('/balance', [AuthController::class, 'Balance']);
        });


    });

    Route::group(['prefix'=>"list"], function () {
        Route::get('/zone', [ListController::class, 'getZonelist']);
        Route::post('/club', [ListController::class, 'getClubList']);
        Route::post('/category', [ListController::class, 'getCategoryList']);
        Route::post('/service', [ListController::class, 'getServiceList']);
        Route::post('/booking', [ListController::class, 'getBookingList']);
        Route::post('/fav-club', [ListController::class, 'getFavClubList']);
        Route::post('/timeslot', [BookingController::class, 'getServiceTimeSlot']);
        Route::get('/customers',[ListController::class , 'customersList'])->middleware('jwt.auth:api','manager');
        Route::get('/service-status',[ListController::class , 'serviceStatusList'])->middleware('jwt.auth:api','manager');
        //slider
        Route::get('/slider',[ListController::class , 'getSlider']);
    });

    Route::group(['middleware' => ['jwt.auth:api','manager'],'prefix'=>'manager'], function () {
        Route::get('/dashboard/analysis', [ManagerController::class, 'analysis']);
        Route::get('/get-service-booking-info', [BookingController::class, 'getServiceBookingInfo']);
      Route::group(['prefix' =>'booking'],function() {
            Route::post('/depoist-money',[BookingController::class,'addServiceBookingPayment']);
            Route::post('/change-service-booking-status',[BookingController::class, 'changeServiceBookingStatus']);
        });
    });
    Route::get('/dashboard/export', [ManagerController::class, 'exportBookingStatusPdf']);

    // ? Test
    Route::post('/send-private-message', function () {
        $data = [
            'text'    => 'Hello! This is a private message.',
            'user_id' => 99, 
            'sender'  => 'Admin',
        ];
    
        try {
            SocketNotify(99, 'Admin', ['msg' => 'Hello! This is a private message.' , 'sender' => 'Admin']);

            return response()->json([
                'status' => 'Message sent successfully',
                'msg' => 'لديك إشعار جديد!',
                // 'node_response' => $response->json(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'Failed to send message',
                'error' => $e->getMessage(),
            ], 500);
        }
    });
    
});




