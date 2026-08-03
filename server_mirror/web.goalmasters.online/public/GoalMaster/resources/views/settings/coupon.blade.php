@extends('layouts.app')
@section('content')
<div class="page-inner">
    <div class="modal fade" id="frmModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Coupon Settings')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Code')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <input type="text" id="code" name="code" placeholder="{{translate('Coupon Code')}}" required="required" class="form-control input-full" data-validation-required-message="code is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Start Date')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <input type="text" id="start_date" name="start_date" placeholder="{{translate('Start Date')}}" required="required" class="form-control input-full dateTimepPckerMinDateToday" data-validation-required-message="Start Date is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('End Date')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <input type="text" id="end_date" name="end_date" placeholder="{{translate('End Date')}}" required="required" class="form-control input-full dateTimepPckerMinDateToday" data-validation-required-message="End Date is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Value')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <input type="number" id="percent" name="percent" placeholder="{{translate('Value')}}"  class="form-control input-full" data-validation-required-message="Value is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Min Order Value')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <input type="number" id="min_order_value" name="min_order_value" placeholder="{{translate('Min Order Value')}}"  class="form-control input-full" data-validation-required-message="Min Order Value is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Max Discount Value')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <input type="number" id="max_discount_value" name="max_discount_value" placeholder="{{translate('Max Discount Value')}}"  class="form-control input-full" data-validation-required-message="Max Discount Value is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Percentage/Fixed')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <select id="is_fixed" name="is_fixed"  class="form-control input-full" data-validation-required-message="Percentage/Fixed is required">
                                    <option value="1">{{translate('Fixed Amount')}}</option>
                                    <option value="0">{{translate('Percentage')}}</option>
                                </select>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Coupon For')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <select id="coupon_type" name="coupon_type"  class="form-control input-full" data-validation-required-message="Coupon Type is required">
                                    <option value="1">{{translate('All User')}}</option>
                                    <option value="2">{{translate('Single User')}}</option>
                                </select>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Customer')}}
                            </label>
                            <div class="col-md-7 controls">
                                <select id="customer_id" name="customer_id"  class="form-control input-full">
                                    <option value="">{{translate('Select One Custome')}}</option>
                                    @foreach($customers as $key => $user)
                                    <option value="{{$user->id}}">{{$user->full_name}}</option>
                                    @endforeach
                                </select>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Use Limit')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-7 controls">
                                <input type="number" id="use_limit" name="use_limit" placeholder="{{translate('Use Limit')}}"  class="form-control input-full" data-validation-required-message="Use Limit is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-5">
                                {{translate('Status')}}
                            </label>
                            <div class="col-md-7 controls">
                                <select id="status" name="status"  class="form-control input-full">
                                    <option value="1">{{translate('Enable')}}</option>
                                    <option value="0">{{translate('Disable')}}</option>
                                </select>
                                <span class="help-block"></span>
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

    <!--coupon datatable-->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('Coupon Info')}}
                        </h4>
                        <button id="btnAdd" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New Coupon')}}
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
<script src="{{ dsAsset('js/custom/settings/coupon.js') }}"></script>
@endpush



@endsection
