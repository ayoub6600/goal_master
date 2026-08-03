@extends('layouts.app')
@section('content')
<div class="page-inner">
    <!--Modal add menu-->
    <div class="modal fade" id="frmModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Booking Info') . ' (Monthly)'}} لإلغاء
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        
{{--                        <div class="form-group control-group form-inline ">--}}

{{--                            <label class="col-md-3">--}}
{{--                                {{translate('Active')}}--}}
{{--                                <span class="required-label">*</span>--}}
{{--                            </label>--}}
{{--                            <div class="col-md-9 controls">--}}
{{--                                <input class="form-check-input" type="checkbox" name="is_monthly_active" id="is_monthly_active">--}}
{{--                            <span class="help-block"></span>--}}
{{--                            </div>--}}
{{--                        </div>--}}
 

                        <div class="form-group control-group form-inline ">
                            <div class="col-md-12">
                                <div class="col-md-auto col-lg-auto col-sm-auto" id="divServiceCalendar">
                                    <div class="row mb-2">
                                        <div class="col-md-12 ">
                                            <label for="serviceDate" >{{translate('Date') . ' بدايه الالغاء '}}</label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12 control-group">
                                            <input id="serviceDate" hidden required name="service_date" class="form-control input-sm" type="text" readonly />
                                            <div id="divServiceDate" style="float: left;"></div>
                                        </div>
                                    </div>

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

    <!-- category datatable -->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('Booking Info') . ' (' . translate('Monthly') . ')'}}
                        </h4>
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
<script src="{{dsAsset('js/custom/booking/monthly-booking.js')}}"></script>
@endpush
@endsection