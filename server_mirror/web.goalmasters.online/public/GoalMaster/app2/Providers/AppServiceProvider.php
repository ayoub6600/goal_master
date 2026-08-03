<?php

namespace App\Providers;

use App\Enums\UserType;
use App\Http\Controllers\Site\WebsiteController;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\View;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\UserManagement\RolePermissionController;
use App\Http\Repository\Language\LanguageRepository;
use App\Http\Repository\UtilityRepository;
use Illuminate\Support\Facades\Session;
use Illuminate\Pagination\Paginator;


class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Paginator::useBootstrap();
        view()->composer('*', function ($view) {

            if (UtilityRepository::isSiteInstalled()==true) {
                $webController = new WebsiteController();
                $langRepo=new LanguageRepository();
                $rtl=Session::get('lang')!=null?((Session::get('lang')->rtl==1)?'rtl':'ltr'):'ltr';
                if (auth::check() && auth::user()->user_type == UserType::SystemUser) {
                    $rolePermission = new RolePermissionController;
                    View::share([
                        'menuList' => $rolePermission->getMenuList(),
                        'userInfo' => auth::user()->only('id', 'name','phone_number', 'photo', 'username', 'is_sys_adm'),
                        'appearance' => $webController->getAppearance(),
                        'language'=>$langRepo->getLanguage(),
                        'rtl'=>$rtl
                    ]);
                } else if (auth::check() && auth::user()->user_type == UserType::WebsiteUser) {
                    View::share([
                        'menuList' => $webController->getMenu(),
                        'appearance' => $webController->getAppearance(),
                        'userInfo' => auth::user()->only('id', 'name','phone_number', 'photo', 'username', 'is_sys_adm'),
                        'language'=>$langRepo->getLanguage(),
                        'rtl'=>$rtl
                    ]);
                } else {
                    View::share([
                        'menuList' => $webController->getMenu(),
                        'appearance' => $webController->getAppearance(),
                        'language'=>$langRepo->getLanguage(),
                        'rtl'=>$rtl
                    ]);
                }
            }
        });
    }
}
