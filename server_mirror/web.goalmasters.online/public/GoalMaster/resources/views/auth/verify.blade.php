@extends('layouts.guest')

@section('content')
<div class="container" dir="rtl" style="text-align: right; font-family: 'Tajawal', sans-serif;">
    <div class="row justify-content-center">
        <div class="col-md-8 mt-5">
            <!-- Success Message -->
            @if (session('success'))
            <div class="alert alert-success text-center" role="alert">
                {{ session('success') }}
            </div>
            @endif

            <!-- Error Message -->
            @if (session('error'))
            <div class="alert alert-danger text-center" role="alert">
                {{ session('error') }}
            </div>
            @endif

            <div class="card shadow-lg border-0">
                <div class="card-header bg-primary text-white text-center fs-4 fw-bold">
                    {{ translate('تأكيد رقم الهاتف') }}
                </div>

                <div class="card-body">
                    <p class="mb-4 fs-5">
                        {{ translate('قبل المتابعة، يرجى التحقق من الواتساب الخاص بك للحصول على كود التحقق.') }}
                    </p>
                    <p class="fs-5">
                        {{ translate('إذا لم تستلم الكود') }}:
                    </p>

                    <form class="d-inline" method="POST" action="{{ route('verification.resend') }}">
                        @csrf
                        <button type="submit" class="btn btn-link p-0 m-0 align-baseline text-decoration-none text-primary">
                            {{ translate('اضغط هنا لطلب كود جديد') }}
                        </button>
                    </form>
                </div>
            </div>

            <div class="card mt-4 shadow-lg border-0">
                <div class="card-body">
                    <form method="POST" action="{{ route('verification.verify') }}">
                        @csrf
                        <div class="mb-3">
                            <label for="code" class="form-label fs-5 fw-bold">{{ translate('أدخل كود التحقق') }}</label>
                            <input type="number" id="code" name="code" class="form-control text-end @error('code') is-invalid @enderror" maxlength="6" required>
                            @error('code')
                            <div class="invalid-feedback text-end">
                                {{ $message }}
                            </div>
                            @enderror
                        </div>
                        <div class="text-center">
                            <button type="submit" class="btn btn-primary px-4">{{ translate('تأكيد') }}</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection