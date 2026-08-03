@extends('layouts.app')
@section('content')
<div class="page-inner">
    <!--Modal-->
    <div class="modal fade" id="frmModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="deginationInputForm" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Add Designation')}}
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
                                <input type="text" id="name" name="name" placeholder="{{translate('Designation name')}}" required class="form-control input-full" data-validation-required-message="Designation name is required !" />
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
                            {{translate('Designation Info')}}
                        </h4>
                        <button id="btnAdd" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New Designation')}}
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
<script src="{{ dsAsset('js/custom/settings/designation.js') }}"></script>
@endpush
@endsection