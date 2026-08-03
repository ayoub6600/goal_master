@extends('layouts.app')
@section('content')
<div class="page-inner">
    <!--Role datatable-->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('SMS Settings')}}
                        </h4>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4">
                            <form class="form-horizontal" action="{{route('sms.twilio')}}" method="POST">
                                @csrf
                            <div class="card">
                                <div class="card-header">                                    
                                    <div class="form-group control-group form-inline">
                                      <label class="switch">
                                        <input id="enable-twilio" {{$twilio->status??0==1?"checked":""}} name="status" type="checkbox" value="1" class="rm-slider" />
                                        <span class="slider round"></span>
                                      </label>
                                      <label class="pt-1 ml-1">
                                        <h5>{{translate('Twilio')}}</h5>
                                      </label>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="form-group row">
                                        <label class="control-label col-3">SID</label>
                                        <input class="form-control col-9" type="text" id="twilio_sid" value="{{$twilio->sid??""}}" name="sid" placeholder="SID">
                                        @if ($errors->has('sid'))
                                            <span class="error text-danger" role="alert">
                                                <strong>{{ $errors->first('sid') }}</strong>
                                            </span>
                                        @endif
                                    </div>
                                    <div class="form-group row">
                                        <label class="control-label col-3">Token</label>
                                        <input class="form-control col-9" type="text" id="twilio_token" value="{{$twilio->token??""}}" name="token" placeholder="Token">
                                        @if ($errors->has('token'))
                                            <span class="error text-danger" role="alert">
                                                <strong>{{ $errors->first('token') }}</strong>
                                            </span>
                                        @endif
                                    </div>
                                    <div class="form-group row">
                                        <label class="control-label col-3">Phone</label>
                                        <input class="form-control col-9" type="text" id="twilio_phone_no" value="{{$twilio->phone_no??""}}" name="phone_no" placeholder="Phone">
                                        @if ($errors->has('phone_no'))
                                            <span class="error text-danger" role="alert">
                                                <strong>{{ $errors->first('phone_no') }}</strong>
                                            </span>
                                        @endif
                                    </div>
                                    <div class="form-group row">                                        
                                        <input type="submit" value="Update" class="btn btn-success btn-sm">
                                    </div>
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
@push("adminScripts")
<script src="{{ dsAsset('js/custom/settings/sms.js') }}"></script>
@endpush
@endsection