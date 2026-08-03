<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta http-equiv="Content-Language" content="en" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>{{$appearance->app_name}}</title>
    <link rel="shortcut icon" href="{{url($appearance->icon)}}">
    <meta name="description" content="{{$appearance->meta_description}}">
    <!-- Meta Keyword -->
    <meta name="keywords" content="{{$appearance->meta_keywords}}">

    <link href="{{ dsAsset('js/lib/assets/css/bootstrap.min.css')}}" rel="stylesheet" />
    <script src="{{ dsAsset('js/lib/assets/js/core/jquery.3.2.1.min.js')}}"></script>
    <link href="{{ dsAsset('css/site.css') }}" rel="stylesheet" />
    <link href="{{ dsAsset('css/custom/user_management/login.css') }}" rel="stylesheet" />
</head>

<body style="background-image: url({{dsAsset($appearance->login_background_image)}});">
    <div class="container-fluid">
        <div class="h-100">
            <div class="h-100 row justify-content-center">
                <div class="h-100 d-flex  align-items-center col-md-12 col-lg-6">
                    <div class="mx-auto app-login-box col-sm-12 col-md-10 col-lg-6 p-4">
                        <h4 class="mb-15rem">
                            <div>{{translate('Reset your Password.')}}</div>
                            <span class="fs-19">{{translate('Use the form below to reset your password.')}}</span>
                        </h4>
                        <div>
                            <form method="POST" action="{{ route('password.update') }}">
                                @csrf
                                <input type="hidden" name="token" value="{{ $token }}" />
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="position-relative form-group">
                                            <label for="email" class="">{{translate('Email address')}}</label>
                                            <input id="email" type="email" class="form-control @error('email') is-invalid @enderror" name="email" value="{{ $email ?? old('email') }}" required autocomplete="email" autofocus />

                                            @error('email')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                            @enderror
                                        </div>
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="position-relative form-group">
                                            <label for="password" class="">{{ translate('New Password') }}</label>
                                            <input id="password" type="password" class="form-control @error('password') is-invalid @enderror" name="password" required autocomplete="new-password" />

                                            @error('password')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                            @enderror
                                        </div>
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="position-relative form-group">
                                            <label for="password-confirm" class="">{{ translate('Confirm Password') }}</label>
                                            <input id="password-confirm" type="password" class="form-control" name="password_confirmation" required autocomplete="new-password" />
                                        </div>
                                    </div>
                                </div>

                                <div class="mt-4 d-flex align-items-center">
                                    <div class="ml-auto">
                                        <button type="submit" class="btn btn-shadow btn-primary">{{ translate('Reset Password') }}</button>
                                    </div>
                                </div>

                                <div class="mt-4  align-items-center text-center">
                                    <a href="{{route('login')}}" class="text-primary">{{translate('Sign in existing account')}}</a>
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