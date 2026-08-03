@extends('site.layouts.site-dashboard')
@section('content-site-dashboard')
@push("css")
<link href="{{ dsAsset('site/css/custom/client/client-pending-booking.css') }}" rel="stylesheet" />
@endpush
@push("scripts")
<script src="{{ dsAsset('site/js/custom/client/client-profile.js') }}"></script>
@endpush



<div class="row">
    <div class="col-md-12">
        <div class="card card-box-shadow">
            <div class="card-header">
                <div class="fs-18 color-black">{{translate('User Info')}}</div>
            </div>
            <form class="form-horizontal p-5 pt-3 mt-1" id="inputForm" novalidate="novalidate" enctype="multipart/form-data">

                <div class="mb-3">
                    <div class="row pl-3 pr-3">
                        <div class="col-md-12">
                            <div class="float-start">
                                <img id="user_photo_view" name="user_photo_view" src="" width="100" height="100" />
                            </div>
                            <div class="float-start ms-2">
                                <input class=" mt-4" name="user_photo" id="user_photo" type="file" />
                        </div>
                    </div>
                </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black w-100">{{translate('Your Name')}} *</span>
                <input name="name" id="name" type="text" required class="form-control w-100" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('User Name')}} *</span>
                <input readonly name="username" id="username" type="text" required class="form-control" />
            </div>
        </div>

        <!-- <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('Email')}} *</span>
                <input readonly name="email" id="email" required type="text" class="form-control" />
            </div>
        </div> -->

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('Phone No')}} *</span>
                <input id="phone_no" type="text" class="form-control" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('Date of Birth')}}</span>
                <input name="dob" id="dob" type="text" class="form-control datePicker" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('Street address')}} *</span>
                <input name="street_address" id="street_address" type="text" class="form-control" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('Street number')}}</span>
                <input name="street_number" id="street_number" type="text" class="form-control" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('State')}}</span>
                <input name="state" id="state" required type="text" class="form-control" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('City')}}</span>
                <input name="city" id="city" required type="text" class="form-control" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('Postal Code')}}</span>
                <input name="postal_code" id="postal_code" type="text" class="form-control" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <span class="color-black">{{translate('Country')}}</span>
                <input name="country" id="country" type="text" class="form-control" />
            </div>
        </div>

        <div class="mb-3">
            <div class="col-md-12">
                <button type="submit" class="btn btn-success float-end">{{translate('Save Change')}}</button>
            </div>
        </div>


        </form>
    </div>
</div>
</div>


@endsection