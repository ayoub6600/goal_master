<?php

use App\Events\BookingCreated;
use App\Events\CardCharged;
use App\Http\Controllers\CalenderController;
use App\Http\Controllers\Dashboard\DashboardController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use App\Mail\TestEmail;
use Illuminate\Support\Facades\Mail;
use App\Http\Controllers\WhatsAppController;
use App\Models\CardSystem\Card;
use App\Models\Customer\CmnCustomer;
use App\Models\Services\SchServices;
use App\Models\User;
use App\Notifications\CardChargedNotification;
use App\Services\OTPService;
use App\Services\WhatsAppService;
use Illuminate\Http\Client\ResponseSequence;
use Illuminate\Http\Request;
use Illuminate\Routing\RouteRegistrar;
use Illuminate\Support\Facades\Notification;

use function PHPSTORM_META\map;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/


Route::group(['middleware' => 'xssProtection'], function () {

    Route::post('charge-card', [App\Http\Controllers\cardController::class, 'chargeCard'])->name('charge-card');


    Route::get('/login', function () {
        return view('auth.login');
    });
    Route::get('/notifications', [DashboardController::class, 'viewNotifications'])->name('notifications.view');
    Route::post('/notifications/markAsRead', [DashboardController::class, 'markAsRead'])->name('notifications.markAsRead');
    Route::post('/notifications/markAsRead-one/{id}', [DashboardController::class, 'markAsReadOne'])->name('notifications.markAsRead.one');
   
    Route::get('/notifications/unread-count', [DashboardController::class, 'unreadCount'])->name('notifications.count');

    
    Route::get('/test', function () {
        $card = Card::where('is_charged', true)->latest()->first();
        $systemUsers = User::where('user_type', '1')->get();
        $user = Auth::user();
        Notification::send($systemUsers, new CardChargedNotification($card, $user));
        event(new CardCharged($systemUsers, $card, $user));
    });

    Auth::routes(['verify' => true]);

    Route::post('is-phone-verified',[App\Http\Controllers\PhoneVerficationController::class, 'is_phone_verified'])->name('is-phone-verified');
    Route::post('send-guest-otp',[App\Http\Controllers\PhoneVerficationController::class, 'guest_phone_Verification_send'])->name('send-guest-otp');
    Route::post('verify-guest-otp',[App\Http\Controllers\PhoneVerficationController::class, 'guest_phone_Verification_verify'])->name('verify-guest-otp');
    Route::post('resend-guest-otp',[App\Http\Controllers\PhoneVerficationController::class, 'guest_phone_Verification_resend'])->name('resend-guest-otp');


    // Auth::routes();
    Route::middleware(['auth', 'phone.not.verified'])->group(function () {
        Route::get('phone-verification', [App\Http\Controllers\PhoneVerficationController::class, 'phoneVerification'])->name('phone.verification');
        Route::post('resend-Code', [App\Http\Controllers\PhoneVerficationController::class, 'phoneVerificationresend'])->name('verification.resend');
        Route::post('phone-verification', [App\Http\Controllers\PhoneVerficationController::class, 'phoneVerificationverify'])->name('verification.verify');
    });
    // Route::group(['middleware' => ['guest.phone.number.verification']], function () {
    //     Route::post('save-site-service-booking', [App\Http\Controllers\Site\SiteController::class, 'saveBooking'])->name('save.site.service.booking');
    // });
    //website route without session
    Route::group(['middleware' => 'verifyWebsiteRoute'], function () {
        Route::get('choose-payment-method/{bookingId?}', [App\Http\Controllers\Site\WebsiteController::class, 'choosePaymentMethod'])->name('choose.payment.method');

        Route::get('/', [App\Http\Controllers\Site\SiteController::class, 'index'])->name('site.home');
        Route::post('save-site-service-booking', [App\Http\Controllers\Site\SiteController::class, 'saveBooking'])->name('save.site.service.booking');
        Route::get('paypal-payment-done', [App\Http\Controllers\Payment\PaypalController::class, 'done'])->name('paypal.payment.done');
        Route::get('payment-complete', [App\Http\Controllers\Site\SiteController::class, 'paymentComplete'])->name('payment.complete');
        Route::get('unsuccessful-payment', [App\Http\Controllers\Site\SiteController::class, 'unsuccessfulPayment'])->name('unsuccessful.payment');
        Route::get('cancel-paypal-payment', [App\Http\Controllers\Payment\PaypalController::class, 'cancel'])->name('cancel.paypal.payment');
  
        //stripe payment
        Route::get('stripe-payment-done', [App\Http\Controllers\Payment\StripeController::class, 'done'])->name('stripe.payment.done');
        Route::get('stripe-payment-cancel', [App\Http\Controllers\Payment\StripeController::class, 'cancel'])->name('stripe.payment.cancel');

        //user balance payment
        Route::get('user-balance-payment-done', [App\Http\Controllers\Payment\UserBalanceController::class, 'done'])->name('user.balance.payment.done');
        Route::get('user-balance-payment-cancel', [App\Http\Controllers\Payment\UserBalanceController::class, 'cancel'])->name('user.balance.payment.cancel');

        Route::post('site-make-online-due-payment', [App\Http\Controllers\Site\SiteController::class, 'serviceDuePayment'])->name('site.make.online.due.payment');
        Route::post('site-cancel-booking', [App\Http\Controllers\Site\SiteController::class, 'cancelBooking'])->name('site.cancel.booking');
        Route::post('site-top-services', [App\Http\Controllers\Site\WebsiteController::class, 'getTopServices'])->name('site.top.services');
        Route::get('site-services', [App\Http\Controllers\Site\WebsiteController::class, 'siteServices'])->name('site.menu.services');
        Route::get('site-teams', [App\Http\Controllers\Site\WebsiteController::class, 'siteTeams'])->name('site.menu.team');
        Route::get('site-photo-gallery', [App\Http\Controllers\Site\WebsiteController::class, 'sitePhotoGallery'])->name('site.photo.gallery');
        Route::get('site-about-us', [App\Http\Controllers\Site\WebsiteController::class, 'siteAboutUs'])->name('site.about.us');
        Route::get('site-faq', [App\Http\Controllers\Site\WebsiteController::class, 'siteFaq'])->name('site.faq');
        Route::get('site-contact', [App\Http\Controllers\Site\WebsiteController::class, 'siteContact'])->name('site.contact');
        Route::post('site-send-client-notification', [App\Http\Controllers\Site\SiteController::class, 'sendClientNotification'])->name('site.send.client.notification');
        Route::get('site-terms-and-condition', [App\Http\Controllers\Site\WebsiteController::class, 'siteTermsAndCondition'])->name('site.terms.and.condition');
        Route::get('site-appoinment-booking', [App\Http\Controllers\Site\WebsiteBookingControllerr::class, 'appoinmentBooking'])->name('site.appoinment.booking');
        Route::get('emb-booking-calendar', [App\Http\Controllers\Site\WebsiteBookingControllerr::class, 'bookingCalendar'])->name('emb.booking-calendar');
        Route::get('single-service-details/{id?}', [App\Http\Controllers\Site\WebsiteController::class, 'serviceDetails'])->name('site.service.single.details');
        Route::get('single-team-details/{id?}', [App\Http\Controllers\Site\WebsiteController::class, 'teamDetails'])->name('site.single.team.details');
        
        
        Route::get('vouchers', [App\Http\Controllers\Site\VoucherController::class, 'index'])->name('site.vouchers');
        Route::get('vouchers/{cmnProduct}', [App\Http\Controllers\Site\VoucherController::class, 'show'])->name('site.vouchers.show');

        Route::get('cart', [App\Http\Controllers\Site\SiteController::class, 'cart'])->name('site.cart');
        Route::post('cart/{cmnProduct}', [App\Http\Controllers\Site\SiteController::class, 'addToCart'])->name('site.cart.add');
        Route::post('cart-remove', [App\Http\Controllers\Site\SiteController::class, 'removeFromCart'])->name('site.cart.remove');

        Route::get('get-coupon-amount', [App\Http\Controllers\Site\SiteController::class, 'getCouponAmount'])->name('get.coupon.amount');
    });


    //common route both of website & adminpanel
    Route::group([], function () {
        Route::get('get-site-service-category', [App\Http\Controllers\Site\SiteController::class, 'getServiceCategory'])->name('get.site.service.category');
        Route::get('get-site-service', [App\Http\Controllers\Site\SiteController::class, 'getService'])->name('get.site.service');
        Route::get('get-site-service-time-slot', [App\Http\Controllers\Site\SiteController::class, 'getServiceTimeSlot'])->name('get.site.service.time.slot');
        Route::get('get-site-branch', [App\Http\Controllers\Site\SiteController::class, 'getBranch'])->name('get.site.branch');
        Route::get('get-site-zone', [App\Http\Controllers\Site\SiteController::class, 'getZone'])->name('get.site.zone');
        Route::get('get-site-payment-type', [App\Http\Controllers\Site\SiteController::class, 'getPaymentType'])->name('get.site.payment.type');
        Route::get('get-site-employee-service', [App\Http\Controllers\Site\SiteController::class, 'getEmployeeService'])->name('get.site.employee.service');
        Route::post('get-site-login-customer-info', [App\Http\Controllers\Site\SiteController::class, 'getLoginCustomerInfo'])->name('get.site.login.customer.info');
        Route::get('get-requested-country-code', [App\Http\Controllers\Site\WebsiteController::class, 'getCountryCode'])->name('get.requested.country.code');
        Route::post('change-language', [App\Http\Controllers\Site\SiteController::class, 'changeLanguage'])->name('change.language');

        ////////////
        // add balanc to user
        Route::post('user-balance-add', [App\Http\Controllers\Payment\UserBalanceController::class, 'add'])->name('user.balance.add');
        ////////////

    });


    Route::group(['middleware' => 'verified'], function () {
        //webiste site route
        Route::group(['middleware' => 'verifyWebsiteRoute'], function () {
            Route::get('client-dashboard', [App\Http\Controllers\Site\ClientDashboardController::class, 'clientDashboard'])->name('client.dashboard');
            Route::get('client-dashboard-last-10-booking', [App\Http\Controllers\Site\ClientDashboardController::class, 'getLast10Booking'])->name('client.dashboard.last.10.booking');
            Route::post('client-dashboard-available-cancel-booking', [App\Http\Controllers\Site\ClientDashboardController::class, 'availableToCancelBooking'])->name('client.dashboard.available.to.cancel.booking');

            Route::get('client-orders', [App\Http\Controllers\Site\ClientOrderController::class, 'index'])->name('site.client.order.index');
            Route::get('client-order/{cmnOrder}', [App\Http\Controllers\Site\ClientOrderController::class, 'show'])->name('site.client.order.show');

            //pending booking
            Route::get('site-client-pending-booking', [App\Http\Controllers\Site\ClientPendingBookingController::class, 'clientPendingBooking'])->name('site.client.pending.booking');
            Route::get('get-client-pending-booking-list', [App\Http\Controllers\Site\ClientPendingBookingController::class, 'getPendingBooking'])->name('get.client.pending.booking.list');

            //done booking
            Route::get('site-done-pending-booking', [App\Http\Controllers\Site\ClientDoneBookingController::class, 'clientDoneBooking'])->name('site.client.done.booking');
            Route::get('get-done-pending-booking-list', [App\Http\Controllers\Site\ClientDoneBookingController::class, 'getDoneBooking'])->name('get.client.done.booking.list');

            //client profile
            Route::get('site-client-profile', [App\Http\Controllers\Site\ClientProfileController::class, 'clientProfile'])->name('site.client.profile');
            Route::post('save-or-update-client-profile', [App\Http\Controllers\Site\ClientProfileController::class, 'saveClientProfile'])->name('save.or.update.client.profile');
            Route::get('get-user-basic-profile', [App\Http\Controllers\Site\ClientProfileController::class, 'getUserBasicInfo'])->name('get.user.profile');

            Route::get('shipping', [App\Http\Controllers\Site\SiteController::class, 'shipping'])->name('site.checkout.shipping');
            Route::post('shipping', [App\Http\Controllers\Site\SiteController::class, 'shippingCart'])->name('site.checkout.shippingInfo');
            Route::get('order', [App\Http\Controllers\Site\SiteController::class, 'orderStore'])->name('site.order.store');
            Route::get('site-order-payment', [App\Http\Controllers\Site\SiteController::class, 'orderPayment'])->name('site.order.payment');
            Route::post('site-order-process-to-payment', [App\Http\Controllers\Site\SiteController::class, 'processToPayOrderAmount'])->name('site.order.process.to.payment');

            Route::get('order/{cmnOrder:code}', [App\Http\Controllers\Site\SiteController::class, 'orderThankyou'])->name('site.order.thankyou');
            Route::get('client-service-feedback/{schServiceFeedback:hash_code}', [App\Http\Controllers\Booking\SchServiceBookingFeedbackController::class, 'edit'])->name('site.client.service.feedback');
            Route::post('client-service-feedback/{schServiceFeedback:hash_code}', [App\Http\Controllers\Booking\SchServiceBookingFeedbackController::class, 'update'])->name('site.client.service.feedback.post');
        });

        //no check permission dropdown
        Route::group(['middleware' => 'verifyUserType'], function () {
            Route::get('get-roles', [App\Http\Controllers\UserManagement\RoleController::class, 'getRoles'])->name('getRoles');
            Route::get('get-branch-dropdown', [App\Http\Controllers\Dropdown\DropdownController::class, 'getBranch'])->name('get.branch.dropdown');
            Route::get('get-zone-dropdown', [App\Http\Controllers\Dropdown\DropdownController::class, 'getZone'])->name('get.zone.dropdown');
            Route::get('get-category-dropdown', [App\Http\Controllers\Dropdown\DropdownController::class, 'getServiceCategory'])->name('get.service.category');
            Route::get('get-employee-dropdown', [App\Http\Controllers\Dropdown\DropdownController::class, 'getEmployee'])->name('get.employee.dropdown');
            Route::get('get-customer-dropdown', [App\Http\Controllers\Dropdown\DropdownController::class, 'getCustomer'])->name('get.customer.dropdown');
            Route::get('get-payment-type-dropdown', [App\Http\Controllers\Dropdown\DropdownController::class, 'getPaymentType'])->name('get.paument.type.dropdown');
            Route::get('get-service-by-category-dropdown', [App\Http\Controllers\Dropdown\DropdownController::class, 'getServiceByCategory'])->name('get.service.by.category.dropdown');
            Route::get('get-customer-user', [App\Http\Controllers\Dropdown\DropdownController::class, 'getUsers'])->name('get.users');
        });



        //no check permission
        Route::group(['middleware' => 'verifyUserType'], function () {
            Route::get('error-display', [App\Http\Controllers\HomeController::class, 'errorDisplay'])->name('error.display');
            Route::get('/home', [App\Http\Controllers\Dashboard\DashboardController::class, 'home'])->name('home');
            Route::get('get-user-info', [App\Http\Controllers\UserManagement\UserController::class, 'getUserInfo'])->name('get.user.info');
            Route::get('get-role', [App\Http\Controllers\UserManagement\RoleController::class, 'getRoleInfo'])->name('get.role.info');

            Route::get('change-password', [App\Http\Controllers\UserManagement\UserController::class, 'changePassword'])->name('change.user.password');
            Route::post('change-user-password', [App\Http\Controllers\UserManagement\UserController::class, 'updateUserPassword'])->name('update.user.password');

            //change profile photo
            Route::get('change-profile-photo', [App\Http\Controllers\UserManagement\UserController::class, 'changeProfilePhoto'])->name('change.user.profile.photo');

            //add menu and permission(add,edit,delete)
            Route::get('add-menu-and-permission', [App\Http\Controllers\UserManagement\AddMenuAndPermission::class, 'addMenuAndPermission'])->name('add.menu.and.permission');
            Route::get('get-menu-and-permission', [App\Http\Controllers\UserManagement\AddMenuAndPermission::class, 'getMenuAndPermission'])->name('get.menu.and.permission');
            Route::post('save-resource', [App\Http\Controllers\UserManagement\AddMenuAndPermission::class, 'createResource'])->name('create.resource');
            Route::post('update-resource', [App\Http\Controllers\UserManagement\AddMenuAndPermission::class, 'updateResource'])->name('update.resource');
            Route::post('delete-resource', [App\Http\Controllers\UserManagement\AddMenuAndPermission::class, 'deleteResource'])->name('delete.resource');
            Route::post('save-permission', [App\Http\Controllers\UserManagement\AddMenuAndPermission::class, 'createPermission'])->name('create.permission');
            Route::post('update-permission', [App\Http\Controllers\UserManagement\AddMenuAndPermission::class, 'updatePermission'])->name('update.permission');
            Route::post('delete-permission', [App\Http\Controllers\UserManagement\AddMenuAndPermission::class, 'deletePermission'])->name('delete.permission');
            Route::post('update-user-profile-photo', [App\Http\Controllers\UserManagement\UserController::class, 'updateUserProfilePhoto'])->name('update.user.profile.photo');

            //get department list
            Route::get('get-department', [App\Http\Controllers\Settings\DepartmentController::class, 'getDepartmentList'])->name('get.department.list');

            // get designation list
            Route::get('get-designation', [App\Http\Controllers\Settings\DesignationController::class, 'getDesignationList'])->name('get.designation.list');

            // get company list
            Route::get('get-company', [App\Http\Controllers\Settings\CompanyController::class, 'companyGet'])->name('company.list');

            //get category list
            Route::get('get-category', [App\Http\Controllers\Services\CategoriesController::class, 'getCategorytList'])->name('get.category.list');

            //get employee off day
            Route::get('get-employee-offday-list', [App\Http\Controllers\Employee\EmployeeController::class, 'getEmployeeCalendar'])->name('get.employee.offday.list');

            //get employee services
            Route::get('get-employee-services', [App\Http\Controllers\Employee\EmployeeController::class, 'getEmployeeServices'])->name('get.employee.services');

            //get branch list
            Route::get('get-branch-list', [App\Http\Controllers\Settings\BranchController::class, 'getBranchList'])->name('get.branch.list');

            //get zone list
            Route::get('get-zone-list', [App\Http\Controllers\Settings\ZoneController::class, 'getZoneList'])->name('get.zone.list');

            //get system user list
            Route::get('get-system-user-list', [App\Http\Controllers\UserManagement\UserController::class, 'getSystemUser'])->name('get.system.user.list');

            //get service list for datatable
            Route::get('get-service', [App\Http\Controllers\Services\ServiceController::class, 'getServiceList'])->name('service.get');

            //get customer
            Route::get('get-customer', [\App\Http\Controllers\Customer\CustomerController::class, 'getAllCustomer'])->name('customer.get');

            //get business holiday
            Route::get('get-business-holiday', [App\Http\Controllers\Settings\BusinessHolidayController::class, 'getBusinessHoliday'])->name('get.business.holiday');

            //get employeey
            Route::get('get-employee',  [App\Http\Controllers\Employee\EmployeeController::class, 'getEmployee'])->name('get.employee');

            Route::get('get-employee-schedule',  [App\Http\Controllers\Employee\EmployeeController::class, 'getEmployeeService'])->name('get.employee.service');

            //get website about us list for datatable
            Route::get('website-get-about-us', [App\Http\Controllers\Website\AboutUsController::class, 'getAboutUs'])->name('website.get.aboutus');

            //get website client testimonial
            Route::get('website-get-client-testimonial', [App\Http\Controllers\Website\ClientTestimonialController::class, 'getClientTestimonial'])->name('website.get.client.testimonial');

            //get website frequently asked question
            Route::get('website-get-frequently-asked-question', [App\Http\Controllers\Website\FrequentlyAskedQuestionController::class, 'getFrequentlyAskedQuestion'])->name('website.get.frequently.asked.question');

            //get website photo gallery
            Route::get('website-get-photo-gallery', [App\Http\Controllers\Website\PhotoGallaryController::class, 'getPhotoGallary'])->name('website.get.photo.gallery');

            //get website menu
            Route::get('website-get-menu', [App\Http\Controllers\Website\WebsiteMenuController::class, 'getWebsiteMenu'])->name('website.get.menu');

            //get user branch list
            Route::get('get-user-branch', [App\Http\Controllers\UserManagement\UserBranchController::class, 'getUserBranch'])->name('get.user.branch');

            //get service booking info
            Route::get('get-service-booking-info', [App\Http\Controllers\Booking\ServiceBookingInfoController::class, 'getServiceBookingInfo'])->name('get.service.booking.info');

            //get employee booking for calendar
            Route::get('get-employee-schedule-calendar', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'getEmployeeSchedule'])->name('get.employee.schedule.calendar');
            Route::get('get-booking-info-by-service-id', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'getBookingInfoByServiceId'])->name('get.booking.info.by.service.id');

            //dashboard 
            Route::get('get-dashboard-common-data', [App\Http\Controllers\Dashboard\DashboardController::class, 'getDashboardCommonData'])->name('get.dashboard.common.data');
            Route::get('get-dashboard-booking-info', [App\Http\Controllers\Dashboard\DashboardController::class, 'getBookingInfo'])->name('get.dashboard.booking.info');
            Route::post('dashboard.change.booking.status', [App\Http\Controllers\Dashboard\DashboardController::class, 'changeBookingStatus'])->name('dashboard.change.booking.status');
            Route::get('export-booking-status', [App\Http\Controllers\Dashboard\DashboardController::class, 'exportBookingStatusPdf'])->name('export.booking.status.pdf');

            //get branch wise business hour
            Route::get('get-branch-wise-business-hours', [App\Http\Controllers\Settings\BusinessHourController::class, 'getBranchWiseBusinessHour'])->name('getbusiness.hour');

            //get branch list for branch datatable
            Route::get('get-branch', [App\Http\Controllers\Settings\BranchController::class, 'branchGet'])->name('get.branch.list');

            //get zone list for zone datatable
            Route::get('get-zone', [App\Http\Controllers\Settings\ZoneController::class, 'zoneGet'])->name('get.zone.list');

            //get employee by service and branch wise
            Route::get('get-employee-by-service', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'getEmployeeByService'])->name('get.employee.by.service');

            //language list
            Route::get('language-list', [App\Http\Controllers\Settings\LanguageController::class, 'getLanguage'])->name('get.language');

            Route::get('translate-language/{id?}', [App\Http\Controllers\Settings\LanguageController::class, 'translateLanguage'])->name('translate.language');
            Route::get('language-translation-list', [App\Http\Controllers\Settings\LanguageController::class, 'translateLanguageList'])->name('language.translation.list');

            Route::get('coupons', [App\Http\Controllers\Settings\CouponController::class, 'index'])->name('coupons');
            Route::get('get-coupons', [App\Http\Controllers\Settings\CouponController::class, 'getCouponList'])->name('coupons.list');
            Route::get('get-coupon/{cmnCoupon}', [App\Http\Controllers\Settings\CouponController::class, 'show'])->name('coupons.show');


            Route::get('salaries', [App\Http\Controllers\Employee\EmployeeController::class, 'salaries'])->name('employee.salaries');
            Route::post('salaries-load', [App\Http\Controllers\Employee\EmployeeController::class, 'salariesLoad'])->name('employee.salaries_load');
            Route::post('salaries-store', [App\Http\Controllers\Employee\EmployeeController::class, 'salariesStore'])->name('employee.salaries_store');
            Route::post('salaries-delete', [App\Http\Controllers\Employee\EmployeeController::class, 'salariesDelete'])->name('employee.salaries_delete');
            Route::get('salaries-processed', [App\Http\Controllers\Employee\EmployeeController::class, 'salariesProcessed'])->name('employee.salaries_processed');
            Route::get('salaries-download', [App\Http\Controllers\Employee\EmployeeController::class, 'salariesDownload'])->name('employee.salaries_download');

            Route::get('get-coupon-amount-from-admin', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'getCouponAmount'])->name('get-coupon-amount-from-admin');

            Route::get('download-service-invoice-order', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'DownloadServiceOrder'])->name('download.service.invoice.order');
        });



        //permission check
        Route::group(['middleware' => ['permission']], function () {
            //user info
            Route::get('user-info', [App\Http\Controllers\UserManagement\UserController::class, 'user'])->name('user.info');
            Route::post('register-new-user', [App\Http\Controllers\UserManagement\UserController::class, 'createUser'])->name('add.new.user');
            Route::post('update-user-info', [App\Http\Controllers\UserManagement\UserController::class, 'updateUserInfo'])->name('edit.user.info');
            Route::post('delete-user-info', [App\Http\Controllers\UserManagement\UserController::class, 'deleteUserInfo'])->name('delete.user.info');

            //Cards System
            Route::get('card', [App\Http\Controllers\cardController::class, 'card'])->name('card');
            Route::post('create-cards', [App\Http\Controllers\cardController::class, 'createCard'])->name('create-cards');
            Route::get('get-cards', [App\Http\Controllers\cardController::class, 'getcards'])->name('getcards');
            Route::get('/cards/pdf/{group_id}', [App\Http\Controllers\cardController::class, 'exportPdf'])->name('cards.pdf');

            //role info
            Route::get('role-info', [App\Http\Controllers\UserManagement\RoleController::class, 'role'])->name('role');
            Route::post('save-role', [App\Http\Controllers\UserManagement\RoleController::class, 'createRole'])->name('add.new.role');
            Route::post('update-role', [App\Http\Controllers\UserManagement\RoleController::class, 'updateRoleInfo'])->name('edit.role.info');
            Route::post('delete-role-info', [App\Http\Controllers\UserManagement\RoleController::class, 'deleteRole'])->name('delete.role.info');

            //role permission
            Route::get('role-permission/{id?}', [App\Http\Controllers\UserManagement\RolePermissionController::class, 'rolePermission'])->name('role.permission');
            Route::post('save-or-update-permission', [App\Http\Controllers\UserManagement\RolePermissionController::class, 'saveOrUpdatePermission'])->name('save.or.update.permission');
            Route::post('update-resource-display-name', [App\Http\Controllers\UserManagement\RolePermissionController::class, 'updateResourceDisplayName'])->name('update.resource.display.name');

            //user branch
            Route::get('user-branch', [App\Http\Controllers\UserManagement\UserBranchController::class, 'userBranch'])->name('user.branch');
            Route::post('save-or-update-user-branch', [App\Http\Controllers\UserManagement\UserBranchController::class, 'saveOrUpdateUserBranch'])->name('save.or.update.user.branch');
            Route::post('delete-user-branch', [App\Http\Controllers\UserManagement\UserBranchController::class, 'deleteUserBranch'])->name('delete.user.branch');


            //department
            Route::get('department', [App\Http\Controllers\Settings\DepartmentController::class, 'department'])->name('department');
            Route::post('department-save', [App\Http\Controllers\Settings\DepartmentController::class, 'createDepartment'])->name('department.add');
            Route::post('department-update', [App\Http\Controllers\Settings\DepartmentController::class, 'updateDepartment'])->name('department.update');
            Route::post('department-delete', [App\Http\Controllers\Settings\DepartmentController::class, 'deleteDepartment'])->name('department.delete');

            // desgination
            Route::get('designation', [App\Http\Controllers\Settings\DesignationController::class, 'designation'])->name('designation');
            Route::post('desgination-store', [App\Http\Controllers\Settings\DesignationController::class, 'designationStore'])->name('designation.store');
            Route::post('designation-edit', [App\Http\Controllers\Settings\DesignationController::class, 'designationEdit'])->name('designation.update');
            Route::post('designation-delete', [App\Http\Controllers\Settings\DesignationController::class, 'designationDelete'])->name('designation.delete');

            // appearance
            Route::get('company', [App\Http\Controllers\Settings\CompanyController::class, 'company'])->name('company');
            Route::post('company-store', [App\Http\Controllers\Settings\CompanyController::class, 'companyStore'])->name('company.add');
            Route::post('company-update', [App\Http\Controllers\Settings\CompanyController::class, 'companyUpdate'])->name('company.update');
            //category
            Route::get('category', [App\Http\Controllers\Services\CategoriesController::class, 'category'])->name('category');
            Route::post('category-save', [App\Http\Controllers\Services\CategoriesController::class, 'createcategory'])->name('category.add');
            Route::post('category-update', [App\Http\Controllers\Services\CategoriesController::class, 'updatecategory'])->name('category.update');
            Route::post('category-delete', [App\Http\Controllers\Services\CategoriesController::class, 'deletecategory'])->name('category.delete');

            //Employee
            Route::get('employee', [App\Http\Controllers\Employee\EmployeeController::class, 'employee'])->name('employee');
            Route::post('save-update-employee-offday', [App\Http\Controllers\Employee\EmployeeController::class, 'saveOrUpdateEmployeeOffDay'])->name('save.update.offday');
            Route::post('delete-employee-offday', [App\Http\Controllers\Employee\EmployeeController::class, 'deleteEmployeeOffday'])->name('delete.employee.offday');
            Route::post('update-employee-offday-by-move', [App\Http\Controllers\Employee\EmployeeController::class, 'updateOffdayByMove'])->name('update.offday.by.move');
            Route::post('employee-store', [App\Http\Controllers\Employee\EmployeeController::class, 'createEmployee'])->name('employee.add');
            Route::post('employee-update', [App\Http\Controllers\Employee\EmployeeController::class, 'updateEmployee'])->name('employee.update');

            // business
            Route::get('business', [App\Http\Controllers\Settings\BusinessHourController::class, 'business'])->name('business.hour');
            Route::post('business-hour-store', [App\Http\Controllers\Settings\BusinessHourController::class, 'businessHourStore'])->name('business.hour.add');
            Route::post('business-update', [App\Http\Controllers\Settings\BusinessHourController::class, 'businessUpdate'])->name('business.hour.update');

            //Branch
            Route::get('branch', [App\Http\Controllers\Settings\BranchController::class, 'branch'])->name('branch');
            Route::post('branch-save', [App\Http\Controllers\Settings\BranchController::class, 'branchStore'])->name('branch.add');
            Route::post('branch-update', [App\Http\Controllers\Settings\BranchController::class, 'updateBranch'])->name('branch.update');
            Route::post('branch-delete', [App\Http\Controllers\Settings\BranchController::class, 'deleteBranch'])->name('branch.delete');
	
			//Zone
			Route::get('zone', [App\Http\Controllers\Settings\ZoneController::class, 'zone'])->name('zone');
			Route::post('zone-save', [App\Http\Controllers\Settings\ZoneController::class, 'zoneStore'])->name('zone.add');
			Route::post('zone-update', [App\Http\Controllers\Settings\ZoneController::class, 'updateZone'])->name('zone.update');
			Route::post('zone-delete', [App\Http\Controllers\Settings\ZoneController::class, 'deleteZone'])->name('zone.delete');
			
            //Service
            Route::get('service', [App\Http\Controllers\Services\ServiceController::class, 'service'])->name('service');
            Route::post('service-save', [App\Http\Controllers\Services\ServiceController::class, 'serviceStore'])->name('service.add');
            Route::post('service-update', [App\Http\Controllers\Services\ServiceController::class, 'serviceUpdate'])->name('service.update');
            Route::post('service-delete', [App\Http\Controllers\Services\ServiceController::class, 'deleteService'])->name('service.delete');

            //Customer
            Route::get('customer', [\App\Http\Controllers\Customer\CustomerController::class, 'customer'])->name('customer');

            Route::post('customer-create', [\App\Http\Controllers\Customer\CustomerController::class, 'customerStore'])->name('customer.store');
            Route::post('customer-update', [\App\Http\Controllers\Customer\CustomerController::class, 'customerUpdate'])->name('customer.update');
            Route::post('customer-delete', [\App\Http\Controllers\Customer\CustomerController::class, 'customerDelete'])->name('customer.delete');


            //business holiday
            Route::get('business-holiday', [\App\Http\Controllers\Settings\BusinessHolidayController::class, 'businessHoliday'])->name('business.holiday');
            Route::post('save-update-business-holiday', [App\Http\Controllers\Settings\BusinessHolidayController::class, 'saveOrUpdateBusinessHoliday'])->name('save.update.business.holiday');
            Route::post('delete-business-holiday', [App\Http\Controllers\Settings\BusinessHolidayController::class, 'deleteBusinessHoliday'])->name('delete.business.holiday');
            Route::post('update-business-holiday-by-move', [App\Http\Controllers\Settings\BusinessHolidayController::class, 'updateBusinessHolidayByMove'])->name('update.business.holiday.by.move');

            //booking calendar
            Route::get('booking-calendar', [CalenderController::class, 'viewCalender'])->name('booking.calendar');
            // Route::get('booking-calendar', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'bookingCalendar'])->name('booking.calendar');
            Route::post('save-service-booking', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'saveBooking'])->name('save.service.booking');
            Route::post('save-service-booking2', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'saveBooking2'])->name('save.service.booking2');
            Route::post('update-service-booking', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'updateBooking'])->name('update.service.booking');
            Route::post('cancel-service-booking', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'cancelBooking'])->name('cancel.service.booking');
            Route::post('done-service-booking', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'doneBooking'])->name('done.service.booking');
            Route::post('delete-service-booking', [App\Http\Controllers\Booking\SchServiceBookingController::class, 'deleteBooking'])->name('delete.service.booking');

            //website apperance
            Route::get('website-appearance', [App\Http\Controllers\Website\AppearanceController::class, 'appearance'])->name('website.appearance');
            Route::post('website-appearance-save-or-update', [App\Http\Controllers\Website\AppearanceController::class, 'saveOrUpdateAppearance'])->name('save.or.update.appearance');

            //About us
            Route::get('website-about-us', [App\Http\Controllers\Website\AboutUsController::class, 'aboutUs'])->name('website.aboutus');
            Route::post('website-save-about-us', [App\Http\Controllers\Website\AboutUsController::class, 'saveAboutUs'])->name('website.save.aboutus');
            Route::post('website-update-about-us', [App\Http\Controllers\Website\AboutUsController::class, 'updateAboutUs'])->name('website.update.aboutus');
            Route::post('website-delete-about-us', [App\Http\Controllers\Website\AboutUsController::class, 'deleteAboutUs'])->name('website.delete.aboutus');

            //Client Testimonial
            Route::get('website-client-testimonial', [App\Http\Controllers\Website\ClientTestimonialController::class, 'clientTestimonial'])->name('website.client.testimonial');
            Route::post('website-save-client-testimonial', [App\Http\Controllers\Website\ClientTestimonialController::class, 'saveClientTestimonial'])->name('website.save.client.testimonial');
            Route::post('website-update-client-testimonial', [App\Http\Controllers\Website\ClientTestimonialController::class, 'updateClientTestimonial'])->name('website.update.client.testimonial');
            Route::post('website-delete-client-testimonial', [App\Http\Controllers\Website\ClientTestimonialController::class, 'deleteClientTestimonial'])->name('website.delete.client.testimonial');

            //frequently asked questions
            Route::get('website-frequently-asked-question', [App\Http\Controllers\Website\FrequentlyAskedQuestionController::class, 'frequentlyAskedQuestion'])->name('website.frequently.asked.question');
            Route::post('website-save-frequently-asked-question', [App\Http\Controllers\Website\FrequentlyAskedQuestionController::class, 'saveFrequentlyAskedQuestion'])->name('website.save.frequently.asked.question');
            Route::post('website-update-frequently-asked-question', [App\Http\Controllers\Website\FrequentlyAskedQuestionController::class, 'updateFrequentlyAskedQuestion'])->name('website.update.frequently.asked.question');
            Route::post('website-delete-frequently-asked-question', [App\Http\Controllers\Website\FrequentlyAskedQuestionController::class, 'deleteFrequentlyAskedQuestion'])->name('website.delete.frequently.asked.Question');

            //Google map
            Route::get('website-google-map', [App\Http\Controllers\Website\GoogleMapController::class, 'googleMap'])->name('website.google.map');
            Route::post('website-save-or-update-google-map', [App\Http\Controllers\Website\GoogleMapController::class, 'saveOrUpdateGoogleMap'])->name('website.save.or.update.google.map');

            //Google map
            Route::get('website-photo-gallery', [App\Http\Controllers\Website\PhotoGallaryController::class, 'photoGallery'])->name('website.photo.gallery');
            Route::post('website-save-photo-gallery', [App\Http\Controllers\Website\PhotoGallaryController::class, 'savePhotoGallery'])->name('website.save.photo.gallery');
            Route::post('website-update-photo-gallery', [App\Http\Controllers\Website\PhotoGallaryController::class, 'updatePhotoGallery'])->name('website.update.photo.gallery');
            Route::post('website-delete-photo-gallery', [App\Http\Controllers\Website\PhotoGallaryController::class, 'deletePhotoGallery'])->name('website.delete.photo.gallery');

            //Terms and conditions
            Route::get('website-terms-and-condition', [App\Http\Controllers\Website\TermsAndConditionController::class, 'termsAndCondition'])->name('website.terms.and.condition');
            Route::post('website-save-or-update-terms-and-condition', [App\Http\Controllers\Website\TermsAndConditionController::class, 'saveOrUpdateTermsAndCondition'])->name('website.save.or.update.terms.condition');

            //Website menu
            Route::get('website-menu', [App\Http\Controllers\Website\WebsiteMenuController::class, 'websiteMenu'])->name('website.menu');
            Route::post('website-save-menu', [App\Http\Controllers\Website\WebsiteMenuController::class, 'saveWebsiteMenu'])->name('website.save.menu');
            Route::post('website-update-menu', [App\Http\Controllers\Website\WebsiteMenuController::class, 'updateWebsiteMenu'])->name('website.update.menu');
            Route::post('website-delete-menu', [App\Http\Controllers\Website\WebsiteMenuController::class, 'deleteWebsiteMenu'])->name('website.delete.menu');

            //Payment Setup
            Route::get('payment-config', [App\Http\Controllers\Payment\PaymentConfigController::class, 'paymentConfig'])->name('payment.config');
            Route::post('save-or-update-currency', [App\Http\Controllers\Payment\PaymentConfigController::class, 'saveOrUpdateCurrency'])->name('save.or.update.currency');
            Route::post('enable-or-disable-local-payment', [App\Http\Controllers\Payment\PaymentConfigController::class, 'enableDisableLocalPayment'])->name('currency.update');
            Route::post('enable-or-disable-paypal-payment', [App\Http\Controllers\Payment\PaymentConfigController::class, 'enableDisablePaypalPayment'])->name('enable.or.disable.paypa.payment');
            Route::post('enable-or-disable-stripe-payment', [App\Http\Controllers\Payment\PaymentConfigController::class, 'enableDisableStripePayment'])->name('enable.or.disable.stripe.payment');
            Route::post('save-or-update-paypal-config', [App\Http\Controllers\Payment\PaymentConfigController::class, 'saveOrUpdatePaypalConfig'])->name('save.or.update.paypal.config');
            Route::post('save-or-update-stript-config', [App\Http\Controllers\Payment\PaymentConfigController::class, 'saveOrUpdateStripeConfig'])->name('save.or.update.stripe.config');

            //service Booking info
            Route::get('service-booking-info', [App\Http\Controllers\Booking\ServiceBookingInfoController::class, 'bookingInfo'])->name('service.booking.info');
            Route::post('change-service-booking-status', [App\Http\Controllers\Booking\ServiceBookingInfoController::class, 'changeServiceBookingStatus'])->name('change.service.booking.status');
            Route::post('add-service-booking-payment', [App\Http\Controllers\Booking\ServiceBookingInfoController::class, 'addServiceBookingPayment'])->name('add.service.booking.payment');

            //email configuration
            Route::get('email-configuration', [App\Http\Controllers\Website\EmailConfigurationController::class, 'emailConfiguration'])->name('email.configuration');
            Route::post('save-email-configuration', [App\Http\Controllers\Website\EmailConfigurationController::class, 'saveEmailConfiguration'])->name('save.email.configuration');

            //language setup
            Route::get('language', [App\Http\Controllers\Settings\LanguageController::class, 'language'])->name('language');
            Route::post('save-language', [App\Http\Controllers\Settings\LanguageController::class, 'saveLanguage'])->name('save.language');
            Route::post('update-language', [App\Http\Controllers\Settings\LanguageController::class, 'updateLanguage'])->name('update.language');
            Route::post('delete-language', [App\Http\Controllers\Settings\LanguageController::class, 'deleteLanguage'])->name('delete.language');
            Route::post('save-translated-language', [App\Http\Controllers\Settings\LanguageController::class, 'saveTranslatedLanguage'])->name('save.translated.language');
            Route::post('update-rtl-status', [App\Http\Controllers\Settings\LanguageController::class, 'updateRtlStatus'])->name('update.rtl.status');

            Route::resource('orders', App\Http\Controllers\Order\OrderController::class);
            Route::resource('products', App\Http\Controllers\Product\ProductController::class);

            Route::post('coupon-save', [App\Http\Controllers\Settings\CouponController::class, 'store'])->name('coupons.store');
            Route::post('coupon-update/{cmnCoupon}', [App\Http\Controllers\Settings\CouponController::class, 'update'])->name('coupons.update');
            Route::post('coupon-delete/{cmnCoupon}', [App\Http\Controllers\Settings\CouponController::class, 'destroy'])->name('coupons.destroy');

            // Twilio
            Route::get('settings/sms', [App\Http\Controllers\Settings\SMSController::class, 'index'])->name('sms.index');
            Route::post('settings/sms/twilio', [App\Http\Controllers\Settings\SMSController::class, 'twilio'])->name('sms.twilio');

            // OTP
            Route::get('settings/otp', [App\Http\Controllers\Settings\SMSController::class, 'otp'])->name('sms.otp');
            Route::post('settings/otp', [App\Http\Controllers\Settings\SMSController::class, 'otpUpdate'])->name('sms.otp.update');
	
			//Monthly Booking
			Route::get('get-monthly-booking', [App\Http\Controllers\Booking\MonthlyBookingController::class, 'getMonthlyBookingList'])->name('get.monthly-booking.list');
	
			Route::get('monthly-booking', [App\Http\Controllers\Booking\MonthlyBookingController::class, 'MonthlyBooking'])->name('monthly-booking');
			Route::post('monthly-booking-update', [App\Http\Controllers\Booking\MonthlyBookingController::class, 'updateMonthlyBooking'])->name('monthly-booking.update');
            Route::get('get-forgiving-generous', [App\Http\Controllers\Booking\MonthlyBookingController::class, 'getForgivingGenerousList'])->name('get.forgiving-generous.list');
            Route::get('forgiving-generous', [App\Http\Controllers\Booking\MonthlyBookingController::class, 'forgivingGenerous'])->name('forgiving-generous');
            
		});
    });
});
