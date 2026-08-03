@extends('layouts.app')
@section('content')
@push("adminScripts")
<script src="{{ dsAsset('js/custom/user_management/user.js') }}"></script>
<link href="{{ 'css/custom/user_management/login.css' }}" rel="stylesheet" />
@endpush

<script>
    $(document).ready(function() {
        isHeaderScrolled = 0;
    });
</script>

<script>
    // Automatically hide the alert after 3 seconds
    setTimeout(function() {
        let successAlert = document.getElementById('success-alert');
        if (successAlert) {
            successAlert.classList.remove('show');
            successAlert.classList.add('fade');
        }
    }, 3000); // 3000 milliseconds = 3 seconds
</script>

<style>
    .slide-down {
        animation: slideDown 0.5s ease-out;
        /* Animation duration and easing */
    }

    @keyframes slideDown {
        from {
            top: -100px;
            /* Start above the viewport */
            opacity: 0;
        }

        to {
            top: 20px;
            /* End at a position slightly below the top */
            opacity: 1;
        }
    }
</style>


<!-- Success Message -->
@if (session('success'))
<div class="alert alert-success alert-dismissible fade show slide-down" role="alert" id="success-alert" style="position: fixed; top: 10%; left: 50%; transform: translate(-50%, -50%); z-index: 9999; min-width: 300px; text-align: center;">
    {{ session('success') }}
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
    </button>
</div>
@endif

<div class="container mt-5" dir="rtl">
    <!-- Large Card Container -->
    <div class="card p-5">
        <h2 class="m-auto">إنشاء كروت جديدة</h2>
        <br><br>
        <form method="post" action="{{ route('create-cards') }}" enctype="multipart/form-data">
            @csrf

            <div class="row mb-4">
                <!-- Dropdown: عدد الخانات -->
                <div class="col-md-3">
                    <label for="numFields" class="form-label">عدد الخانات</label><br>
                    <input type="number" class="form-control" id="numFields" placeholder="من 8 الى 20" name="codeLength" min="8" max="20">
                </div>

                <!-- Dropdown: صيغة الأرقام -->
                <div class="col-md-3">
                    <label for="numberFormat" class="form-label">صيغة كود الكارت</label><br>
                    <select class="form-control" id="numberFormat" name="formula">
                        <option selected>اختر صيغة الكود</option>
                        <option value="letters_numbers">حروف وأرقام</option>
                        <option value="letters">حروف</option>
                        <option value="numbers">أرقام</option>
                    </select>
                </div>

                <!-- Input: العدد -->
                <div class="col-md-3">
                    <label for="quantity" class="form-label">عدد الكروت</label>
                    <input type="number" class="form-control" id="quantity" placeholder="" name="card_count">
                </div>



                <!-- Input: سعر الكارت -->
                <div class="col-md-3">
                    <label for="cardPrice" class="form-label">سعر الكارت الواحد</label>
                    <input type="number" class="form-control" id="cardPrice" placeholder="" name="price">
                </div>
            </div>

            <!-- error masseges -->
            <div class="row mb-4">
                <div class="col-md-3">

                    @error('codeLength')
                    <div class="alert alert-danger ">{{ $message }}</div>
                    @enderror

                </div>


                <div class="col-md-3">
                    @error('price')
                    <div class="alert alert-danger ">{{ $message }}</div>
                    @enderror
                </div>

                <div class="col-md-3">
                    @error('formula')
                    <div class="alert alert-danger ">{{ $message }}</div>
                    @enderror
                </div>


                <div class="col-md-3">
                    @error('card_count')
                    <div class="alert alert-danger ">{{ $message }}</div>
                    @enderror
                </div>


            </div>

            <!-- Create Button -->
            <div class="row mb-4 text-center">
                <div class="col-md-12">
                    <!-- <button class="btn btn-lg btn-primary">
                        <i class="fas fa-arrow-left"></i> إنشاء
                        <i class="fas fa-arrow-right"></i> 
                    </button> -->
                    <button type="submit" class="btn-wide btn-shadow btn btn-primary float-end">إنشاء</button>
                </div>
            </div>

        </form>


    </div>
</div>


@endsection