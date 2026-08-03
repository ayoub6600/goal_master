@extends('layouts.app')
@section('content')
<div class="page-inner">
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('Booking Info')}}
                        </h4>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="row">
                                <div class="col-md-6">
                                    <span>{{translate('Date From')}}</span>
                                    <input type="text" id="dateFrom" class="form-control input-full datePicker" value="{{now()->sub('30 days')->format('Y-m-d')}}">
                                </div>
                                <div class="col-md-6">
                                    <span>{{translate('Date To')}}</span>
                                    <input type="text" id="dateTo" class="form-control input-full datePicker" value="{{now()->format('Y-m-d')}}">
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <span>{{translate('Employee')}}</span>
                            <select id="employeeId" class="form-control input-full" data-live-search="true"></select>
                        </div>

                        <div class="col-md-3">
                            <span>{{translate('Customer')}}</span>
                            <select id="customerId" class="form-control " data-live-search="true"></select>
                        </div>
                       <div class="col-md-3">
                            <span>{{translate('Branch')}}</span>
                            <select id="branchId" class="form-control input-full" data-live-search="true"></select>
                        </div>
                    </div>
                    <div class="row mt-2">
                    <div class="col-md-10">
                            <div class="row">
                                <div class="col-md-6">
                                    <span>{{translate('Service Status')}}</span>
                                    <select id="serviceStatus" class="form-control input-full">
                                        <option value="">{{translate('All')}}</option>
                                        <option selected value="0">{{translate('Pending')}}</option>
                                        <option value="1">{{translate('Processing')}}</option>
                                        <option value="2">{{translate('Approved')}}</option>
                                        <option value="3">{{translate('Cancel')}}</option>
                                        <option value="4">{{translate('Done')}}</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <span>{{translate('Booking No')}} </span>
                                    <input type="number" id="serviceId" placeholder="{{translate('Booking No')}}" class="form-control input-full" />
                                </div>

                            </div>

                        </div>
                        <div class="col-md-2 pt-20 d-flex justify-content-between gap-5">
                            <button id="btnFilter" class="btn btn-sm btn-primary"><i class="fas fa-filter"></i> {{translate('Filter')}}</button>
                            <button id="btnInternet" class="btn btn-sm btn-danger"><i class="fas fa-money-bill"></i> الحساب</button>
                        </div>
                        
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <table id="tableElement" class="table table-bordered w100"></table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <!--Modal-->

    <div class="modal fade" id="frmPayModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputPayForm" novalidate="novalidate">
                    <div class="modal-body">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                            {{translate('Booking No#')}} <span id="span-booking-no"></span>
                            </span>
                        </h5>
                        <input type="hidden" id="id" name="id" />
                        <div class="form-group control-group form-inline">
                            <div class="row">
{{--                                <div class="col-md-12">--}}
{{--                                    <div class="col-md-auto col-lg-auto col-sm-auto" id="divServiceCalendar">--}}
{{--                                        <div class="row">--}}
{{--                                            <div class="col-md-12">--}}
{{--                                                <label for="serviceDate" >{{translate('Service Date')}}</label>--}}
{{--                                            </div>--}}
{{--                                        </div>--}}
{{--                                        <div class="row">--}}
{{--                                            <div class="col-md-12 control-group">--}}
{{--                                                <input id="serviceDate" required name="service_date" class="form-control input-sm" type="text" readonly />--}}
{{--                                                <div id="divServiceDate" style="float: left;"></div>--}}
{{--                                            </div>--}}
{{--                                        </div>--}}

{{--                                    </div>--}}

{{--                                </div>--}}
                                <div class="col-md-12 mt-3 control-group">
                                    <label for="due" class="float-left m-2">{{translate('Due')}}</label>
                                    <input type="number" name="due" id="due" class="form-control" required min="1">
{{--                                    <textarea id="remarks" name="remarks" class="form-control" rows="2"></textarea>--}}
                                </div>

                            </div>
                        </div>

                        {{------------- radio button-----------------}}
                        <div class="col-md-12 mt-3 control-group d-flex align-items-center">
                            <input type="radio" name="payment_status" id="payed" value="1" class="mr-2">
                            <label for="payed" class="mr-3">{{translate('دفعه')}}</label>
                        
                            <input type="radio" name="payment_status" id="tolerance" value="0" class="mr-2" checked>
                            <label for="tolerance">{{translate('مسامحة')}}</label>
                        </div>
                        
                        <div class="col-md-12 mt-3 control-group" id="extraInputDiv" style="display: none;">
                            <label for="extraInput" class="float-left m-2">{{translate('مبلغ المسامحه')}}</label>
                            <input type="text" name="extra_input" id="extraInput" class="form-control">
                        </div>
                        
                        <div class="modal-footer pb-0 pr-2">
                            <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">{{translate('Close')}}</button>
                            <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>

                        </div>
                    </div>
                </form>

            </div>
        </div>
    </div>

    <div class="modal fade" id="frmModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate">
                    <div class="modal-body">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                            {{translate('Booking No#')}} <span id="span-booking-number"></span>
                            </span>
                        </h5>
                        <input type="hidden" id="booking_id" name="booking_id" />
                        <div class="form-group control-group form-inline">
                            <div class="row">
                                <div class="col-md-12">
                                    <span>{{translate('Service Status')}}</span>
                                    <select id="status" name="status" class="form-control input-full">
                                        <option selected value="0">{{translate('Pending')}}</option>
                                        <option value="1">{{translate('Processing')}}</option>
                                        <option value="2">{{translate('Approved')}}</option>
                                        <option value="3">{{translate('Cancel')}}</option>
                                        <option value="4">{{translate('Done')}}</option>
                                    </select>
                                </div>
                                <!--<div class="col-md-12 control-group">-->
                                <!--    <div class="form-group control-group form-inline">-->
                                <!--        <label class="switch">-->
                                <!--            <input id=email_notify name="email_notify" type="checkbox" value="1" class="rm-slider">-->
                                <!--            <span class="slider round"></span>-->
                                <!--        </label>-->
                            <!--        <label class="pt-1 ml-1"> {{translate('Send notification by email')}}</label>-->
                                <!--        <span class="help-block"></span>-->
                                <!--    </div>-->
                                <!--</div>-->
                            </div>
                        </div>

                        <div class="modal-footer pb-0 pr-2">
                            <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">{{translate('Close')}}</button>
                            <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>

                        </div>
                </form>

            </div>
        </div>
    </div>




</div>
{{--- model internet payed done ---}}
<div class="modal fade" id="internetModal" tabindex="-1" role="dialog" aria-labelledby="internetModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="internetModalLabel">تاكيد العمليه</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>{{translate('هل انت متاكد من تاكيد العمليه؟')}}</p>
                <div class="row">
                    <div class="col-md-6">
                        <span>{{translate('Date From')}}</span>
                        <input type="text" id="dateFromModal" class="form-control input-full datePicker" value="{{now()->sub('30 days')->format('Y-m-d')}}">
                    </div>
                    <div class="col-md-6">
                        <span>{{translate('Date To')}}</span>
                        <input type="text" id="dateToModal" class="form-control input-full datePicker" value="{{now()->format('Y-m-d')}}">
                    </div>
                    <div class="col-md-6">
                        <span>{{translate('Branch')}}</span>
                        <select id="branchIdModel" class="form-control input-full" data-live-search="true"></select>
                    </div>  
                </div>
                
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Cancel')}}</button>
                <button type="button" class="btn btn-primary" id="confirmPayment">{{translate('تاكيد')}}</button>
            </div>
        </div>
    </div>
</div>

@push("adminScripts")
<script src="{{ dsAsset('js/custom/booking/booking-info.js') }}"></script>
@endpush


@endsection