@extends('layouts.app')
@section('content')
<div class="page-inner">
    <div class="row">
        <div class="offset-md-2 col-md-8">
            <div class="main-card card">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate" enctype="multipart/form-data">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                <i class="fas fa-cog"></i> {{translate('Email Settings')}}
                            </h4>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Mailer')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" value="{{env('MAIL_MAILER')}}" id="mail_mailer" name="mail_mailer" required="required" class="form-control input-full" data-validation-required-message="Host is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Host')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" value="{{env('MAIL_HOST')}}" id="mail_host" name="mail_host" required="required" class="form-control input-full" data-validation-required-message="Host is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>


                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Port')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="number" value="{{env('MAIL_PORT')}}" id="mail_port" name="mail_port" required="required" class="form-control input-full" data-validation-required-message="Port is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Username/email')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" value="{{env('MAIL_USERNAME')}}" id="mail_username" name="mail_username" required="required" class="form-control input-full" data-validation-required-message="Username/email is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Password')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" value="{{env('MAIL_PASSWORD')}}" id="mail_password" name="mail_password" required="required" class="form-control input-full" data-validation-required-message="Username/email password is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <div class="col-md-9 offset-md-3">
                            <label class="switch">
                                <input id="force_add" name="force_add" type="checkbox" value="1" class="rm-slider" autocomplete="off">
                                <span class="slider round"></span> <span class="ml-5">{{translate('Force add new configuration')}}</span>
                            </label>
                            <div class="mt-2">{{translate("At first try to update, if not update then check force update. Don't try before update.")}} </div>                             
                        </div>

                    </div>

                    <div class="modal-footer">
                        <button type="submit" class="btn btn-success">{{translate('Save Change')}}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

@push("adminScripts")
<script src="{{ dsAsset('js/custom/website/email-configuration.js') }}"></script>
@endpush

@endsection