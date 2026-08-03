@extends('layouts.app')
@section('content')
<div class="page-inner">
    <!--Modal-->
    <div class="modal fade" id="frmModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                            {{translate('Branch Info')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Name')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="text" id="name" name="name" placeholder="{{translate('Branch name')}}" required class="form-control input-full" data-validation-required-message="Branch name is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>


                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Phone')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="number" id="phone" name="phone" placeholder="{{translate('Phone number')}}" required class="form-control input-full" data-validation-required-message="Phone Number is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>


                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Email')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="email" id="email" name="email" placeholder="{{translate('Email address number')}}" required class="form-control input-full" data-validation-required-message="Email address is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Address')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <textarea rows="5" id="address" name="address" required class="form-control input-full" data-validation-required-message="Email address is required"></textarea>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Lat')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="text" id="lat" name="lat" placeholder="{{translate('Lat')}}" required class="form-control input-full" data-validation-required-message="lat is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Long')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="text" id="long" name="long" placeholder="{{translate('Long')}}" required class="form-control input-full" data-validation-required-message="long is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Order')}}
                            </label>
                            <div class="col-md-9 controls">
                                <input type="number" id="order" name="order" placeholder="{{translate('Order value')}}" class="form-control input-full" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Zone')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <select id="zone_id" name="zone_id" class=" form-control input-full">

                                </select>
                                <span class="help-block"></span>
                            </div>
                        </div>


                        <div class="form-group form-inline">
                            <label class="col-md-3 col-form-label">{{translate('Status')}}</label>
                            <div class="col-md-9">
                                <div class="form-check">
                                    <label class="form-radio-label">
                                        <input id="statusYes" type="radio" name="status" class="form-radio-input" value="1" checked="checked" />
                                        <span class="form-radio-sign pl-1"> {{translate('Active')}}</span>
                                    </label>
                                    <label class="form-radio-label">
                                        <input id="statusNo" type="radio" class="form-radio-input" name="status"
                                               value="0" />
                                        <span class="form-radio-sign pl-1"> {{translate('Inactive')}}</span>
                                    </label>
                                </div>
                            </div>
                        </div>

                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">{{translate('Close')}}</button>
                        <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>

                    </div>
                </form>

            </div>
        </div>
    </div>


    <!--Role datatable-->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('Branch Info')}}
                        </h4>
                        <button id="btnAdd" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New Branch')}}
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <table id="tableElement" class="table table-bordered w100"></table>
                </div>
            </div>
        </div>
    </div>
</div>
@push("adminScripts")
<script src="{{ dsAsset('js/custom/settings/branch.js') }}"></script>
@endpush
@endsection