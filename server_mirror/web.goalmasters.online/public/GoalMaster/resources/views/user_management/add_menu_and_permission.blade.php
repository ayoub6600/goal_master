@extends('layouts.app')
@section('content')
<div class="page-inner">


    <!--Modal add menu-->
    <div class="modal fade" id="frmMenuModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="menuForm" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Add Menu')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">


                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('View Page Name')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-8 controls">
                                <input type="text" id="name" name="name" placeholder="{{translate('View Page/File Name')}}" required class="form-control input-full" data-validation-required-message="View file/Page name is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('Menu/Display Name')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-8 controls">
                                <input type="text" id="displayName" name="displayName" placeholder="{{translate('Menu/Display Name')}}" required class="form-control input-full" data-validation-required-message="Menu/Display name is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('Font Awesome Icon Class')}}
                            </label>
                            <div class="col-md-8 controls">
                                <input type="text" id="faIcon" name="faIcon" placeholder="{{translate('Font Awesome Icon Class')}}" class="form-control input-full" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('Menu Level')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-8 controls">
                                <select id="level" name="level" class="form-control input-full" data-validation-required-message="Menu level is required" required>
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                    <option value="3">3</option>
                                </select>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('Menu Under')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-8 controls">
                                <select id="secResourceId" name="secResourceId" class="form-control input-full">
                                </select>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('Menu Serial/Order')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-8 controls">
                                <input type="text" id="menuSerial" name="menuSerial" placeholder="{{translate('Menu Serial/Order')}}" required class="form-control input-full" data-validation-required-message="Menu Serial/Order is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('Route Name')}}
                            </label>
                            <div class="col-md-8 controls">
                                <input type="text" id="routeName" name="routeName" placeholder="{{translate('Route Name')}}" class="form-control input-full" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group form-inline">
                            <label class="col-md-4 col-form-label">{{translate('Status')}}</label>
                            <div class="col-md-8">
                                <div class="form-check">
                                    <label class="form-radio-label">
                                        <input id="statusYes" type="radio" name="status" class="form-radio-input" value="1" checked="checked" />
                                        <span class="form-radio-sign pl-1"> {{translate('Active')}}</span>
                                    </label>
                                    <label class="form-radio-label">
                                        <input id="statusNo" type="radio" class="form-radio-input" name="status" value="0" />
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




    <!--Modal add menu permission-->
    <div class="modal fade" id="frmPermissionModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="permissionForm" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Add Permission')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">


                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('Permission Name')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-8 controls">
                                <input type="text" id="permissionName" name="permissionName" placeholder="{{translate('Permission Name(Add,Edit,Delete)')}}" required class="form-control input-full" data-validation-required-message="Permission name is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-4">
                                {{translate('Route Name')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-8 controls">
                                <input type="text" id="permissionRouteName" name="permissionRouteName" placeholder="{{translate('Route Name')}}" required class="form-control input-full" data-validation-required-message="Route Name is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group form-inline">
                            <label class="col-md-4 col-form-label">{{translate('Status')}}</label>
                            <div class="col-md-8">
                                <div class="form-check">
                                    <label class="form-radio-label">
                                        <input id="permiStatusYes" type="radio" name="status" class="form-radio-input" value="1" checked="checked" />
                                        <span class="form-radio-sign pl-1"> {{translate('Active')}}</span>
                                    </label>
                                    <label class="form-radio-label">
                                        <input id="permiStatusNo" type="radio" class="form-radio-input" name="status" value="0" />
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
                            <i class="fas fa-bars"></i> {{translate('Menu And Permission')}}
                        </h4>
                        <button id="btnAddNewMenu" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Create New Menu')}}
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <table id="tableElement" class="table table-bordered"></table>
                </div>
            </div>
        </div>
    </div>
</div>
@push("adminScripts")
<script src="{{ dsAsset('js/custom/user_management/add-menu-and-permission.js') }}"></script>
@endpush
@push("adminCss")
<link href="{{ dsAsset('css/custom/user_management/add-menu-and-permission.css') }}" rel="stylesheet" />
@endpush
@endsection