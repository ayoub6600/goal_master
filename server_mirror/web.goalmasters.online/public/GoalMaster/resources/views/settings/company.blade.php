@extends('layouts.app')
@section('content')
<div class="page-inner">
    <div class="row">
        <div class="col-md-8 offset-md-2">
            <div class="main-card card">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                <i class="fas fa-cog"></i> {{translate('Company Settings')}}
                            </h4>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Name')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="name" name="name" placeholder="{{translate('Company Name')}}" required="required" class="form-control input-full" data-validation-required-message="name is required"/>
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Address')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="address" name="address" placeholder="{{translate('address')}}" required="required" class="form-control input-full" data-validation-required-message="Address is required"/>
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            Phone
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="phone" name="phone" placeholder="{{translate('phone')}}"  class="form-control input-full" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Mobile')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="mobile" name="mobile" placeholder="{{translate('mobile')}}"  class="form-control input-full" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Email')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="email" name="email"  class="form-control input-full" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Web Address')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="web_address" name="web_address"   class="form-control input-full"/>
                            <span class="help-block"></span>
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
<script src="{{ dsAsset('js/custom/settings/company.js') }}"></script>
@endpush

@endsection
