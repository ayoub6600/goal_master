@extends('layouts.app')
@section('content')
<div class="page-inner">
    <!--Modal-->
    <div class="modal fade" id="frmRoleModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="roleForm" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Role Info')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">


                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Role Name')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="text" id="name" name="name" placeholder="{{translate('Role name')}}" required class="form-control input-full" data-validation-required-message="Role name is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group form-inline">
                            <label class="col-md-3 col-form-label">{{translate('Is Default Role')}}</label>
                            <div class="col-md-9">
                                <div class="form-check">
                                    <label class="form-radio-label">
                                        <input id="isDefaultRoleYes" type="radio" name="isDefaultRole" class="form-radio-input" value="1" />
                                        <span class="form-radio-sign pl-1"> {{translate('Yes')}}</span>
                                    </label>
                                    <label class="form-radio-label">
                                        <input id="isDefaultRoleNo" type="radio" class="form-radio-input" name="isDefaultRole" value="0" checked="checked" />
                                        <span class="form-radio-sign pl-1"> {{translate('No')}}</span>
                                    </label>
                                </div>
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


    <!--Role datatable-->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            <i class="fas fa-user-tag"></i> {{translate('Role Information')}}
                        </h4>
                        <button id="btnAddRole" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New Role')}}
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
<script src="{{ dsAsset('js/custom/user_management/role.js') }}"></script>
@endpush

@endsection