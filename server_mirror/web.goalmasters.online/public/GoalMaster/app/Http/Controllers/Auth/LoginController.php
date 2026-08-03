<?php

namespace App\Http\Controllers\Auth;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use Illuminate\Foundation\Auth\AuthenticatesUsers;

class LoginController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles authenticating users for the application and
    | redirecting them to your home screen. The controller uses a trait
    | to conveniently provide its functionality to your applications.
    |
    */

    use AuthenticatesUsers;

    /**
     * Where to redirect users after login.
     *
     * @var string
     */
    protected $redirectTo = RouteServiceProvider::HOME;

    public function redirectTo()
    {
        if (auth()->user()->user_type == UserType::SystemUser)
            return $this->redirectTo;
        return RouteServiceProvider::ClientDashboard;
    }

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('guest')->except('logout');
    }

    public function username()
    {
        $login = request()->input('username');
        if (preg_match('/^\+?[0-9]{10,15}$/', $login)) {
            $field = 'phone_number';
        } else {
            $field = 'username';
        }
        request()->merge([$field => $login]);
        return $field;
    }

    // public function username()
    // {
    //     $login = request()->input('username');
    //     if (filter_var($login, FILTER_VALIDATE_EMAIL)) {
    //         $field = 'email';
    //     } else {
    //         $field = 'username';
    //     }
    //     request()->merge([$field => $login]);
    //     return $field;
    // }

}
