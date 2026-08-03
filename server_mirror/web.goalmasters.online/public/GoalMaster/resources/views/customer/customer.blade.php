@extends('layouts.app')
@section('content')
@push("adminScripts")
<script src="{{ dsAsset('js/lib/country-list.js') }}"></script>
<script src="{{dsAsset('js/custom/customer/customer.js')}}"></script>
@endpush


<div class="page-inner">

    <!--Modal add menu-->
    <div class="modal fade" id="frmModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate" enctype="multipart/form-data">

                    
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Customer Info')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>


                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-7">
                                <div class="form-group control-group form-inline controls">
                                    <label>{{translate('Customer Name')}} *</label>
                                    <input type="text" id="full_name" name="full_name" placeholder="{{translate('Full name')}}" required data-validation-required-message="Customer name is required" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                            <!-- <div class="col-md-5">
                                <div class="form-group control-group form-inline controls">
                                    <label>{{translate('System User')}}</label>
                                    <select name="user_id" id="user_id" class="form-control input-full">
                                        <option value="">a</option>
                                    </select>
                                    <span class="help-block"></span>
                                </div>
                            </div> -->
                        </div>

                        <!-- <div class="form-group control-group form-inline controls">
                            <label>Customer Email *</label>
                            <input type="email" id="email" name="email" placeholder="email@example.com" required data-validation-required-message="Email address is required" class="form-control input-full" />
                            <span class="help-block"></span>
                        </div> -->

                        <div class="row">
                            <div class="col-md-7">
                                <div class="form-group control-group form-inline controls">

                                    <label class="col-md-12 p-0">{{translate('Customer Phone')}} *</label>
                                    <input type="tel" id="phone_no" maxlength="20" name="phone_no" placeholder="{{translate('Phone Number')}}" required data-validation-required-message="Phone number is required" class="form-control input-full w-100" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                            <div class="col-md-5">
                                <div class="form-group control-group form-inline controls">
                                    <label>{{translate('Date of Birth')}} </label>
                                    <input type="text" id="dob" name="dob" class="form-control input-full datePicker" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
<!-- 
                        <div class="form-group control-group form-inline ">
                            <label>{{translate('Street Address')}} *</label>
                            <textarea type="text" id="street_address" name="street_address" required data-validation-required-message="Street address is required" class="form-control input-full"></textarea>
                            <span class="help-block"></span>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline controls">
                                    <label>{{translate('Country')}}</label>
                                    <input type="text" id="country" name="country" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline controls">
                                    <label>{{translate('City')}}</label>
                                    <input type="text" id="city" name="city" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div> -->
                        <!-- <div class="row">
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline controls">
                                    <label>{{translate('State Name')}}</label>
                                    <input type="text" id="state" name="state" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline controls">
                                    <label>{{translate('Postal Code')}}</label>
                                    <input type="number" id="postal_code" name="postal_code" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline controls">
                            <label>{{translate('Remarks')}}</label>
                            <input type="text" id="remarks" name="remarks" class="form-control input-full" />
                            <span class="help-block"></span>
                        </div> -->

                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">{{translate('Close')}}</button>
                        <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- category datatable -->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('Customer Information')}}
                        </h4>
                        <button id="btnAdd" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New Customer')}}
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


@endsection