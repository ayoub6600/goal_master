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
                                {{translate('About Us')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="id" value="" id="id" />
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline ">
                                    <div class="row">
                                        <div class="col-md-5">
                                            <img id="about-image-view" width="100%" class="float-left" />
                                            <span class="mt-2">{{translate('Image Size 658x542')}}</span>
                                        </div>
                                        <div class="col-md-7">
                                            <input type="file" id="image_url" accept="image/*" name="image_url" class="mt-5" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label> {{translate('Title')}}
                                        <span class="required-label">*</span>
                                    </label>
                                    <input type="text" id="title" name="title" placeholder="Title" required class="form-control input-full" data-validation-required-message="Title is required" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label>
                                        {{translate('Details')}}
                                        <span class="required-label">*</span>
                                    </label>
                                    <textarea rows="6" maxlength="3000" id="details" name="details" class="form-control input-full" required data-validation-required-message="About details is required"></textarea>
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label> {{translate('Order')}}
                                    </label>
                                    <input type="number" id="order" name="order" placeholder="{{translate('Order')}}" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label class="switch">
                                        <input id=status name="status" type="checkbox" value="1" class="rm-slider">
                                        <span class="slider round"></span>
                                    </label>
                                    <label class="pt-1 ml-1"> {{translate('Is Active')}}</label>
                                    <span class="help-block"></span>
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
                            {{translate('About Us')}}
                        </h4>
                        <button id="btnAdd" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New')}}
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
<script src="{{ dsAsset('js/custom/website/about-us.js') }}"></script>
@endpush

@endsection