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
                            {{translate('FAQ')}}
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
                                <div class="form-group control-group form-inline">
                                    <label>{{translate('Question')}}
                                        <span class="required-label">*</span>
                                    </label>
                                    <input type="text" id="question" name="question" placeholder="{{translate('Question')}}" required class="form-control input-full" data-validation-required-message="Question is required" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label>
                                    {{translate('Answer')}}
                                        <span class="required-label">*</span>
                                    </label>
                                    <textarea rows="6" maxlength="1000" id="answer" name="answer" class="form-control input-full" required data-validation-required-message="Answer is required"></textarea>
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-12 controls">
                                <div class="form-group control-group form-inline">
                                    <label> {{translate('Order')}}
                                    </label>
                                    <input type="text" id="order" name="order" placeholder="{{translate('Order/Serial')}}" class="form-control input-full" />
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
                            {{translate('FAQ List')}}
                        </h4>
                        <button id="btnAdd" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New FAQ')}}
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
<script src="{{ dsAsset('js/custom/website/frequently-asked-question.js') }}"></script>
@endpush

@endsection