@extends('site.layouts.site')
@section('content')
@push("css")
<link href="{{ dsAsset('site/css/custom/choose-payment-method.css') }}" rel="stylesheet" />
@endpush


<div class="row">
    <div class="col-md-4 offset-md-4 mt-4">
        <div class="main-card  card">
            <div class="card-header">
                <div class="d-flex align-items-center">
                    <h4 class="card-title">
                        {{translate('Choose your desired payment partner')}}
                    </h4>

                </div>
            </div>
            <div class="card-body">
                <div class="row d-flex justify-content-center">
                    <div class="w100" id="divPaymentMethod">
                        @foreach($paymentMethod->all() as $pay)
                        @if ($pay['type']!=1)

                        <div class="payment-chose-div float-start {{$pay['type']==2?'payment-chose':''}}">
                            <input {{$pay['type']==2?'checked':''}} type="radio" name="payment_type" value="{{$pay['id']}}" class="float-start payment-radio d-none" />
                            <div class="float-start color-black p-2">
                                @if ($pay['type']==2)
                                <img src="img/payment-paypal.svg" />
                                @elseif ($pay['type']==3)
                                <img src="img/payment-stripe.svg" />
                                @elseif ($pay['type']==4)
                                <img src="img/payment-user-balance.svg" />
                                @endif
                            </div>
                        </div>
                        @endif
                        @endforeach
                    </div>
                </div>
                <div class="row">
                    <div class="col mt-5 d-flex justify-content-center">
                        <button id="btnNext" type="button" class="btn btn-booking btn-lg">{{translate('Process To Pay')}}</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@push("scripts")
<script src="{{ dsAsset('site/js/custom/choose-payment-method.js') }}"></script>
@endpush


@endsection