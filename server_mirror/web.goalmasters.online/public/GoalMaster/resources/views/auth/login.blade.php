<!doctype html>
<html lang="ar" dir="rtl">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Content-Language" content="en">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta content='width=device-width, initial-scale=1.0, shrink-to-fit=no' name='viewport' />
    <title>{{$appearance->app_name}} Login</title>
    <link rel="shortcut icon" href="{{url($appearance->icon)}}">

    <meta name="description" content="{{$appearance->meta_description}}">
    <!-- Meta Keyword -->
    <meta name="keywords" content="{{$appearance->meta_keywords}}">

    <!-- Disable tap highlight on IE -->
    <meta name="msapplication-tap-highlight" content="no">
    <link href="{{ dsAsset('js/lib/assets/css/bootstrap.min.css')}}" rel="stylesheet" />
    <script src="{{ dsAsset('js/lib/assets/js/core/jquery-3.6.0.min.js') }}"></script>
    <link href="{{ dsAsset('css/custom/user_management/login.css') }}" rel="stylesheet" />
    <link href="{{ dsAsset('css/site.css') }}" rel="stylesheet" />
</head>
<body class="login-bg" style="background-image: url({{dsAsset($appearance->login_background_image)}}); text-align: right">

    <div class="container-fluid">
        <div class="h-100">
            <div class="h-100 row justify-content-center">
                <div class="h-100 d-flex  align-items-center col-md-12 col-lg-6">
                    <div class="mx-auto app-login-box col-sm-12 col-md-10 col-lg-6 p-4">
                        <h4 class="mb-0">
                            <span class="d-block">{{translate('Welcome back')}},</span>
                            <span class="fs-19">{{translate('Please sign in to your account.')}}</span>
                        </h4>
                        <h6 class="mt-3">{{translate('No account')}}؟ <a href="{{ route('register') }}" class="text-primary">{{translate('Sign up')}}
                        {{translate('now')}}</a></h6>
                        <div class="divider row"></div>
                        <div>
                            <form method="POST" action="{{ route('login') }}">
                                @csrf
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="position-relative form-group">
                                            <label for="username" class="">{{ translate('Phone') }}</label>
                                            <input id="username" type="text" class="form-control @error('username') is-invalid @enderror" name="username" value="{{ old('username') }}" required autocomplete="username" autofocus placeholder="{{translate('ادخل رقم الهاتف أو اسم المستخدم')}}" />

                                            @error('username')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                            @enderror

                                        </div>
                                    </div>
                                    <div class="col-md-12">
                                        <div class="position-relative form-group">
                                            <label for="password" class="">{{ translate('Password') }}</label>
                                            <input id="password" type="password" class="form-control @error('password') is-invalid @enderror" name="password" required autocomplete="current-password" placeholder="ادخل كلمة السر هنا">

                                            @error('password')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                            @enderror
                                        </div>
                                    </div>
                                </div>
                                <div class="position-relative form-check">
                                    <input class="form-check-input" type="checkbox" name="remember" id="remember" {{ old('remember') ? 'checked' : '' }}>
                                    <label style="cursor: pointer; margin-right: 20px;" class="form-check-label" for="remember">{{ translate('Remember Me') }}</label>
                                </div>
                                <div class="d-flex align-items-center">
                                    <div class="ml-auto">
                                        <button type="submit" class="btn btn-shadow btn-primary">{{ translate('Click to Login') }}</button>
                                    </div>

                                </div>

                                <!-- <div class="align-items-center text-center mt-5">
                                    <button id="btnAdmin" class="btn btn-sm btn-primary">Admin User</button>
                                    <button id="btnStaff" class="btn btn-sm btn-info">Staff User</button>
                                    <button id="btnWebUser" class="btn btn-sm btn-success">Web User</button>
                                    <script>
                                        $("#btnAdmin").on('click',function(){
                                            $("#username").val('admin');
                                            $("#password").val('12345678');
                                        });
                                        $("#btnStaff").on('click',function(){
                                            $("#username").val('staff');
                                            $("#password").val('12345678');
                                        });
                                        $("#btnWebUser").on('click',function(){
                                            $("#username").val('webuser');
                                            $("#password").val('12345678');
                                        });
                                    </script>
                                </div> -->

                                <div class="align-items-center text-center mt-5">
                                    @if (Route::has('password.request'))
                                    <a class="btn-lg btn btn-link fs-16" href="{{ route('password.request') }}">
                                        {{ translate('Forgot Your Password?') }}
                                    </a>
                                    @endif
                                </div>

                                <div class="align-items-center text-center">
                                    <a class="btn-lg btn btn-link fs-16" href="{{ route('site.home') }}">
                                        {{ translate('Go to Website') }}
                                    </a>
                                </div>

                              

                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>

</html>