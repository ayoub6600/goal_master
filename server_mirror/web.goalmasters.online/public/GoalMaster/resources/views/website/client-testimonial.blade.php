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
                                {{translate('Client Testimonial')}}
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
                                        <div class="col-md-4">
                                            <div class="col p-0"> <img id="image-view" width="80" height="80" /></div>
                                            <div class="col p-0"> <span class="mt-2">{{translate('Image Size 80x80')}}</span></div>
                                        </div>
                                        <div class="col-md-8">
                                            <input type="file" id="image" accept="image/*" name="image" class="mt-3" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label>{{translate('Client Name')}}
                                        <span class="required-label">*</span>
                                    </label>
                                    <input type="text" id="name" name="name" placeholder="{{translate('Client name')}}" required class="form-control input-full" data-validation-required-message="Client is required" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label>
                                        {{translate('Description')}}
                                        <span class="required-label">*</span>
                                    </label>
                                    <textarea rows="6" maxlength="500" id="description" name="description" class="form-control input-full" required data-validation-required-message="Description is required"></textarea>
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label> {{translate('Rating')}}
                                    </label>
                                    <select type="number" id="rating" name="rating" class="form-control input-full">
                                        <option value="1">1</option>
                                        <option value="2">2</option>
                                        <option value="3">3</option>
                                        <option value="4">4</option>
                                        <option value="5">5</option>
                                    </select>
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label> {{translate('Phone')}}
                                    </label>
                                    <input type="text" id="contact_phone" name="contact_phone" placeholder="{{translate('Phone No')}}" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label> {{translate('Email')}}
                                    </label>
                                    <input type="email" id="contact_email" name="contact_email" placeholder="{{translate('Email Address')}}" class="form-control input-full" />
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


    <!--datatable-->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('Client Testimonial')}}
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
<script src="{{ dsAsset('js/custom/website/client-testimonial.js') }}"></script>
@endpush




@endsection