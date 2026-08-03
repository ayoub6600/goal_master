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
                                {{translate('Product Add')}}
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
                                <input type="text" id="name" name="name" placeholder="{{translate('Name')}}" required="required" class="form-control input-full" data-validation-required-message="name is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Type')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <select id="cmn_type_id" name="cmn_type_id"  class="form-control input-full" data-validation-required-message="Type is required">
                                    <option value="1">{{translate('Product')}}</option>
                                    <option value="2">{{translate('Voucher')}}</option>
                                </select>
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Thumbnail')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-6 controls">
                                <input type="file" accept="image/*" id="thumbnail" name="thumbnail" placeholder="{{translate('Thumbnail')}}" class="form-control input-full"/>
                                <span class="help-block"></span>
                            </div>
                            <div class="col-md-3">
                                <img src="" id="thumbnail_img" class="img-thumbnail">
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Voucher Value')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="number" id="price" name="price" placeholder="{{translate('Value')}}" required="required" class="form-control input-full" data-validation-required-message="Price is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Discount %')}}
                            </label>
                            <div class="col-md-9 controls">
                                <input type="number" id="discount" name="discount" value="0" placeholder="{{translate('Discount %')}}" class="form-control input-full"/>
                                <span class="help-block"></span>
                            </div>
                        </div>
                         <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Quantity')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="number" id="quantity" name="quantity" placeholder="{{translate('Quantity')}}" required="required" class="form-control input-full" data-validation-required-message="Quantity is required"/>
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('Status')}}
                            </label>
                            <div class="col-md-9 controls">
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
                            {{translate('Product Informaton')}}
                        </h4>
                        <button id="btnAdd" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New Product')}}
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
<script src="{{ dsAsset('js/custom/product/product.js') }}"></script>
@endpush

@endsection
