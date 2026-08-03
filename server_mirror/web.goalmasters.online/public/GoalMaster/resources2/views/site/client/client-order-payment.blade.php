@extends('site.layouts.site')
@section('content')
@push("css")
<link href="{{ dsAsset('site/css/custom/client/client-order-payment.css') }}" rel="stylesheet" />
@endpush


<div class="page-inner">
    <div class="row">
        <div class="col-md-4 offset-md-4 mt-4">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('Choose a way to pay')}}
                        </h4>
                    </div>
                </div>
                <div class="card-body d-flex justify-content-center">
                    <div class="w100" id="divPaymentMethod">

                    </div>
                </div>
                <div class="row">
                    <div class="col mt-3 justify-content-center d-flex p-3">
                        <button id="btnMakePayment" type="button" class="btn btn-booking btn-lg">{{translate('Make Payment')}}</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@push("scripts")
<script src="{{ dsAsset('site/js/custom/client/site-order-payment.js') }}"></script>
@endpush


@endsection