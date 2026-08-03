@extends('site.layouts.site')
@section('content')
@push("css")
<link href="{{ 'css/custom/user_management/login.css' }}" rel="stylesheet" />
@endpush

<script>
    $(document).ready(function() {
        isHeaderScrolled = 0;
    });
</script>
<div class="whole-wrap">
    <div class="container mt-5">
        <div class="section-top-border">
            <div class="h-100">
                <div class="h-100 row justify-content-center">
                    <div class="h-100 d-flex  align-items-center col-md-12 col-lg-6">
                        <div class="mx-auto app-login-box col-sm-12 col-md-10 col-lg-12 p-4">
                            <div class="app-logo"></div>
                            <h4>
                                <div>{{translate('Welcome to')}} {{$appearance->app_name}}</div>
                                <span class="fw-light">
                                {{translate('It only takes a few seconds to create your account')}}
                                </span>
                            </h4>
                            <div>
                                <form method="POST" action="{{ route('register') }}">
                                    @csrf
                                    <div class="row">
                                        <!-- <div class="col-md-12">
                                            <div class="position-relative mb-3">
                                                <label for="email" class="">
                                                    <span class="text-danger">*</span> {{translate('Email')}}
                                                </label>
                                                <input id="email" type="email" placeholder="{{translate('Email address')}}" class="form-control @error('email') is-invalid @enderror" name="email" value="{{ old('email') }}" required autocomplete="email" autofocus />
                                                @error('email')
                                                <span class="invalid-feedback" role="alert">
                                                    <strong>{{ $message }}</strong>
                                                </span>
                                                @enderror
                                            </div>
                                        </div> -->
                                        <div class="col-md-6">
                                            <div class="position-relative mb-3">
                                                <label for="username" class="">
                                                    <span class="text-danger">*</span> {{translate('User Name')}}
                                                </label>
                                                <input id="username" type="text" maxlength="99" placeholder="{{translate('User Name')}}" class="form-control @error('username') is-invalid @enderror" name="username" value="{{ old('username') }}" required autofocus />
                                                @error('username')
                                                <span class="invalid-feedback" role="alert">
                                                    <strong>{{ $message }}</strong>
                                                </span>
                                                @enderror
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="position-relative mb-3">
                                                <label for="name" class="">{{translate('Name')}}</label>
                                                <input id="name" type="text" class="form-control @error('name') is-invalid @enderror" placeholder="{{translate('Name here')}}" name="name" value="{{ old('name') }}" required autocomplete="name" autofocus />
                                                @error('name')
                                                <span class="invalid-feedback" role="alert">
                                                    <strong>{{ $message }}</strong>
                                                </span>
                                                @enderror
                                            </div>
                                        </div>
                                        <!--#######################################################-->
                                        <div class="col-md-12">
                                            <div class="position-relative mb-3">
                                                <label for="name" class="">{{translate('Phone Number')}}</label>
                                                <input id="phone_no" type="number" class="form-control @error('phone_no') is-invalid @enderror" placeholder="{{translate('Phone Number')}}" name="phone_no" value="{{ old('phone_no') }}" required autocomplete="phone_no" autofocus />
                                                @error('phone_no')
                                                <span class="invalid-feedback" role="alert">
                                                    <strong>{{ $message }}</strong>
                                                </span>
                                                @enderror
                                            </div>
                                        </div>
                                        <!--#######################################################-->
                                        <div class="col-md-6">
                                            <div class="position-relative mb-3">
                                                <label for="examplePassword" class="">
                                                    <span class="text-danger">*</span> {{translate('Password')}}
                                                </label>
                                                <input id="password" type="password" class="form-control @error('password') is-invalid @enderror" name="password" placeholder="{{translate('Password here')}}" required autocomplete="new-password" />

                                                @error('password')
                                                <span class="invalid-feedback" role="alert">
                                                    <strong>{{ $message }}</strong>
                                                </span>
                                                @enderror
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="position-relative mb-3">
                                                <label for="password_confirmation" class="">
                                                    <span class="text-danger">*</span> {{translate('Repeat Password')}}
                                                </label>
                                                <input placeholder="{{translate('Repeat Password here')}}" id="password-confirm" type="password" class="form-control" name="password_confirmation" required autocomplete="new-password" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mt-3 position-relative form-check">
                                        <label for="exampleCheck" class="form-check-label">
                                        <input name="check" id="exampleCheck" type="checkbox" class="form-check-input" />
                                            اوافق على 
                                            <a href="{{route('site.terms.and.condition')}}">{{translate('Terms and Conditions')}}</a>.
                                        </label>
                                    </div>
                                    <div class="row mt-4">
                                        <div class="w-auto">
                                            <h6 class="mb-0">
                                            {{translate('Already have an account')}}?
                                                <a href="{{route('login')}}" class="text-primary">{{translate('Sign in')}}</a>
                                            </h6>
                                        </div>
                                        <div class="col">
                                                <button type="submit" class="btn-wide btn-shadow btn btn-primary float-end">{{translate('Create Account')}}</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</div>

@endsection