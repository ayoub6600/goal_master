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
                            {{translate('SMS OTP Settings')}}
                        </h4>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-12">
                            <form class="form-horizontal" action="{{route('sms.otp.update')}}" method="POST">
                                @csrf
                            <div class="card">
                                <div class="card-header">                                    
                                    <div class="form-group control-group form-inline">
                                      <label class="switch">
                                        <input id="enable-otp" {{$otp->status??0==1?"checked":""}} name="status" type="checkbox" value="1" class="rm-slider" />
                                        <span class="slider round"></span>
                                      </label>
                                      <label class="pt-1 ml-1">
                                        <h5>{{translate('OTP')}}</h5>
                                      </label>
                                    </div>
                                </div>
                                <div class="card-body">
                                    @foreach($otp_messages as $key => $opt_message)
                                    <div class="form-group row">
                                        <label class="control-label col-12">{{$opt_message->message_for}}</label>
                                        <code class="col-12">{{$opt_message->tags}}</code>
                                        <div class="col-12">
                                            <textarea class="form-control" name="message[{{$opt_message->id}}]">{{$opt_message->message}}</textarea>    
                                        </div>                                        
                                    </div>
                                    @endforeach
                                    <div class="form-group row">
                                        <div class="col-12">                                        
                                            <input type="submit" value="Update" class="btn btn-success btn-sm">
                                        </div>
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