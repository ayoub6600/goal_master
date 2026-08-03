@extends('layouts.app')
@section('content')
@push("adminScripts")
<script src="{{dsAsset('js/lib/jquery-schedule-plus/js/jq.schedule.plus.js')}}"></script>
<script src="{{dsAsset('js/custom/booking/booking-calendar.js')}}"></script>
@endpush

@push("adminCss")
<link href="{{ dsAsset('js/lib/jquery-schedule-plus/css/style.css')}}" rel="stylesheet" />
<link href="{{ dsAsset('css/custom/booking/booking-calendar.css')}}" rel="stylesheet" />
@endpush
<html lang="ar">
<div class="page-inner">

    <div class="row">
        <div class="col-md-12">
            <div class="row" id="date-form">
                <div style="display: none;">
                    <span>{{translate('Add mutiple:')}}</span>
                    <input id="mutipleY" name="mutiple" type="radio" value="1" checked="true" />
                    <label for="mutipleY">{{translate('Yes')}}</label>&nbsp;
                    <input id="mutipleN" name="mutiple" type="radio" value="0" />
                    <label for="mutipleN">{{translate('No')}}</label>&nbsp;
                </div>
                <div class="col-md-11 mb-2">
                    <div class="row">
                        <div class="col-md-7">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <select class="form-control filter-item" id="filter_zone_id"></select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <select class="form-control filter-item" id="filter_cmn_branch_id"></select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <select class="form-control filter-item" id="filter_sch_employee_id" data-live-search="true">
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <select class="form-control filter-item" id="filter_cmn_customer_id" data-live-search="true">
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="row">
                                <div class="col-md-12">
                                    <select class="form-control filter-item" id="Hour">
                                        <option value="0" selected>5 Minute</option>
                                        <option value="1">10 Minute</option>
                                        <option value="2">15 Minute</option>
                                        <option value="3">30 Minute</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="row">
                                <div class="col-md-8">
                                    <input type="text" id="filter_date" class="datePicker form-control filter-item" value="{{date('Y-m-d')}}" placeholder="{{translate('Date')}}" />
                                </div>
                                <div class="col-md-4">
                                    <div class="mt-1" id="divPreNext">
                                        <i id="iFilterPrvDate" title="{{translate('Previous day')}}" class="iFilterChangeDate fa fa-chevron-left float-left"></i>
                                        <i id="iFilterNextDate" title="{{translate('Next day')}}" class="iFilterChangeDate fa fa-chevron-right float-right"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row  mt-2">
                        <div class="col-md-3">
                            <div class="input-group mb-3">
                                <input type="number" class="form-control" id="filter_booking_info_id" placeholder="Order No" aria-label="Recipient's username" aria-describedby="basic-addon2">
                                <div class="input-group-append">
                                    <button class="btn btn-primary btn-sm" type="button" id="btnPreviewInvoice">{{translate('Preview')}}</button>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="input-group mb-3">
                                <input type="number" class="form-control" id="filter_booking_id" placeholder="Booking No" aria-label="Recipient's username" aria-describedby="basic-addon2">
                                <div class="input-group-append">
                                    <button class="btn btn-success btn-sm" type="button" id="btnViewBookingNo">{{translate('Load')}}</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-1">
                    <div class="row">
                        <div class="col-md-12">
                            <button id="reload_timeline" class="btn btn-primary btn-sm pull-right">{{translate('Load')}}</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="separetor"></div>
                </div>

                <div class="col-md-12">
                    <div class="row">
                        <div class="col-md-10" id="highlight-color">
                            <div>
                                <span class="text"><b>{{translate('Total Booking')}} :</b> <span id="total-booking"></span></span>
                            </div>
                            <div>
                                <span class="bg_done color"></span> <span class="text">{{translate('Done')}} : <span id="done-booking"></span></span>
                            </div>
                            <div>
                                <span class="bg_cancel color"></span> <span class="text">{{translate('Cancel')}} : <span id="cancel-booking"></span> </span>
                            </div>
                            <div>
                                <span class="bg_approved color"></span> <span class="text">{{translate('Approved')}} : <span id="approved-booking"></span></span>
                            </div>
                            <div>
                                <span class="bg_processing color"></span> <span class="text">{{translate('Processing')}} : <span id="processing-booking"></span></span>
                            </div>
                            <div>
                                <span class="bg_pending color"></span> <span class="text">{{translate('Pending')}} : <span id="pending-booking"></span></span>
                            </div>
                        </div>
                        <div class="col-md-2 pb-2">
                            <button class="btn btn-success btn-sm pull-right" id="btnAddSchedule"><i class="fas fa-plus-circle"></i> {{translate('Add Schedule')}}</button>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Schedule table/calendar -->
    <div class="row" id="topScheduleContent">
        <div class="col-md-12 col-lg-12 col-sm-12 col-xs-12" id="scheduleContent">
            <div id="schedule"></div>
        </div>
    </div>
    <!-- end schedule table/calendar -->


    <!-- add schedule modal -->
    <div class="modal fade" id="frmAddScheduleModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputFormBooking" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Add/Edit Service')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">

                       <section>
    <div class="form-row">
        <div class="col-md-3 control-group">
            <label for="sch_employee_id" class="float-left">{{translate('Staff')}}</label>
            <select required id="sch_employee_id" name="sch_employee_id" class="serviceInput form-control" data-live-search="true">
                <option value="">{{translate('Select One')}}</option>
            </select>
        </div>
        <div class="col-md-3 control-group">
            <label for="sch_service_id" class="float-left">{{translate('Service')}}</label>
            <select required id="sch_service_id" name="sch_service_id" class="serviceInput form-control" data-live-search="true">
                <option value="">{{translate('Select One')}}</option>
            </select>
        </div>
        <div class="col-md-3 control-group">
            <label for="sch_service_category_id" class="float-left">{{translate('Category')}}</label>
            <select required id="sch_service_category_id" name="sch_service_category_id" class="serviceInput form-control">
            </select>
        </div>
        <div class="col-md-3 control-group">
            <label for="cmn_branch_id" class="float-left">{{translate('Branch')}}</label>
            <select required id="cmn_branch_id" name="cmn_branch_id" class="serviceInput form-control">
            </select>
        </div>
    </div>
                            <div class="form-row mt-2">
                                <div class="col-md-auto col-lg-auto col-sm-auto" id="divServiceCalendar">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="serviceDate" class="float-left">{{translate('Service Date')}}</label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12 control-group">
                                            <input id="serviceDate" required name="service_date" class="form-control input-sm" type="text" readonly />
                                            <div id="divServiceDate" style="float: left;"></div>
                                        </div>
                                    </div>

                                </div>
                                <div class="col">
                                    <div id="divTopDays">
                                        <div class="row">
                                            <div class="col-md-12">
                                                <div class="float-left" id="divDaysName"></div>
                                                <div class="float-right" id="divPreNext">
                                                    <i id="iPrvDate" title="{{translate('Previous day')}}" class="iChangeDate fa fa-chevron-left float-left"></i>
                                                    <i id="iNextDate" title="{{translate('Next day')}}" class="iChangeDate fa fa-chevron-right float-right"></i>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row divServiceAvaiable">
                                            <div class="col-md-12" id="divServiceAvaiableTime">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="col divSelectedService">
                                    <i class="fa fa-calendar float-left pl-2 mt-1 mr-1" aria-hidden="true"></i>
                                    <i id="iSelectedServiceText" class=""></i>
                                </div>

                                <div class="col-md-auto col-lg-auto col-sm-auto float-end">
                                    <button type="button" class="btn btn-success float-end" id="add-service-btn"><i class="fas fa-plus-circle"></i> {{translate('Add more service')}}</button>
                                </div>

                            </div>

                            <div class="form-row d-none" id="div-service-summary">
                                <div class="col-md-12">
                                    <table id="tbl-service-cart" class="table table-bordered fs-13 text-start">
                                        <thead>
                                            <tr>
                                                <th>{{translate('SL')}}</th>
                                                <th>{{translate('Service')}}</th>
                                                <th>{{translate('Staff')}}</th>
                                                <th>{{translate('Date')}}</th>
                                                <th>{{translate('Time')}}</th>
                                                <th>{{translate('Fee')}}</th>
                                                <th class="text-center">{{translate('Opt')}}</th>
                                            </tr>
                                        </thead>
                                        <tbody class="text-start" id="iSelectedServiceList"></tbody>
                                    </table>

                                </div>

                                <div class="col-md-12">
                                    <div class="float-right mb-3 mt-2"><b>{{translate('Total Amount:')}} <span id="service-total-amount"></span> </b> </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="float-right"><b>{{translate('Discount Amount:')}} <span id="service-discount-amount">0</span> </b> </div>
                                </div>

                                <div class="col-md-12 control-group">
                                    <label for="coupon_code" class="float-left">{{translate('Apply Coupon Code')}}</label>
                                    <div class="input-group">
                                        <input id="coupon_code" name="coupon_code" class="form-control" data-live-search="true" />
                                        <div class="input-group-append">
                                            <button id="btn-apply-coupon" class="btn btn-success btn-sm" type="button"> {{translate('Apply Coupon')}}</button>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="float-right mt-4"><b>{{translate('Payable Amount:')}} <span id="service-payable-amount"></span> </b> </div>
                                </div>


                            </div>

                            <div class="form-row">
                                <div class="col-md-12 mt-3 control-group">
                                    <label for="cmn_customer_id" class="float-left">{{translate('Customer')}} <b class="color-red"> *</b> </label>
                                    <div class="input-group">
                                        <select required id="cmn_customer_id" name="cmn_customer_id" class="form-control" data-live-search="true"></select>
                                        <div class="input-group-append">
                                            <button id="btnAddNewCustomer" class="btn btn-primary btn-sm" type="button"><i class="fas fa-plus-circle"></i> {{translate('Add Customer')}}</button>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12 mt-3">
                                    <div class="row">
                                        <div class="col-md-7 control-group">
                                            <label for="cmn_payment_type_id" class="float-left">{{translate('Payment By')}}<b class="color-red"> *</b></label>
                                            <select required id="cmn_payment_type_id" name="cmn_payment_type_id" class="form-control"></select>
                                        </div>
                                        <div class="col-md-5 control-group">
                                            <label for="paid_amount" class="float-left">{{translate('Paid Amount')}}</label>
                                            <input required type="number" id="paid_amount" name="paid_amount" class="form-control" min="0" onkeyup=enforceMinMax(this) />
                                            <div id="divPaymentStatus" class="d-none">{{translate('Paid/Unpaid')}}</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12 mt-3">
                                    <div class="row">
                                        <div class="col-md-12 control-group">
                                            <label for="status" class="float-left">{{translate('Application Status')}}</label>
                                            <select required id="status" name="status" class="form-control">
                                                <option value="2">{{translate('Approved')}}</option>
                                                <option value="0">{{translate('Pending')}}</option>
                                                <option value="1">{{translate('Processing')}}</option>
                                                <option value="3">{{translate('Cancel')}}</option>
                                                <option value="4">{{translate('Done')}}</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12 mt-3 control-group">
                                    <label for="remarks" class="float-left">{{translate('Remarks')}}</label>
                                    <textarea id="remarks" name="remarks" class="form-control" rows="2"></textarea>
                                </div>
                                <!-- <div class="col-md-12 control-group">
                                    <div class="form-group control-group form-inline">
                                        <label class="switch">
                                            <input id=email_notify name="email_notify" type="checkbox" value="1" class="rm-slider">
                                            <span class="slider round"></span>
                                        </label>
                                        <label class="pt-1 ml-1"> {{translate('Send booking notification by email')}}</label>
                                        <span class="help-block"></span>
                                    </div>
                                </div> -->
                            </div>
                        </section>



                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-success btn-sm">Save Change</button>

                    </div>
                </form>

            </div>
        </div>
    </div>
    <!-- end add schedule modal -->

    <!--schedule details view modal -->
    <div class="modal fade details-view-modal" id="modalViewScheduleDetails" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header d-none">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="col-md-12">
                        <div id="task-details-body-wrap">
                            <div id="task-details-body-wrap-user">
                                <img id="scheduleEmployeeImage" src="" alt="user image">
                                <h4 id="scheduleEmployee"></h4>
                                <p id=scheduleSpecialist></p>
                            </div>
                            <div id="task-details-body-wrap-task">
                                <p>Branch: <span id="scheduleBranch"></span></p>
                                <p>Customer: <span id="scheduleCustomer"></span></p>
                                <p>Phone: <span id="scheduleCustomerPhone"></span></p>
                                <!-- <p>Email: <span id="scheduleCustomerEmail"></span></p> -->
                                <p>Service Booking Date: <span id="scheduleServiceBookingDate"></span></p>
                                <p>Service Date: <span id="scheduleServiceDate"></span></p>
                                <p>Service: <span id="scheduleService"></span></p>
                                <p>Service Time: <span id="scheduleServiceTime"></span></p>
                                <p>Paid Amount: <span id="schedulePaidAmount"></span></p>
                                <p>Remarks: <span id="scheduleRemarks"></span></p>
                                <p>Service Status: <span id="scheduleServiceStatus"></span></p>

                            </div>
                        </div>
                    </div>
                    <!-- <div class="col-md-12 control-group">
                        <div class="form-group control-group form-inline">
                            <label class="switch">
                                <input id=view_schedule_email_notify name="view_schedule_email_notify" type="checkbox" value="1" class="rm-slider">
                                <span class="slider round"></span>
                            </label>
                            <label class="pt-1 ml-1"> Send notification by email</label>
                            <span class="help-block"></span>
                        </div>
                    </div> -->
                </div>
                <div class="modal-footer pt-0">
                    <button type="button" id="btn-schedule-delete" class="btn btn-danger btn-sm" title="Delete Booking"><i class="far fa-trash-alt"> </i> Delete</button>
                    <button type="button" id="btn-schedule-cancel" class="btn btn-warning btn-sm" title="Cancel Booking"><i class="fas fa-times-circle"></i> Cancel</button>
                    <button type="button" id="btn-schedule-edit" class="btn btn-primary btn-sm float-left" title="Edit Booking"><i class="far fa-edit"></i> Edit</button>
                    <button type="button" id="btn-schedule-done" class="btn btn-success btn-sm" title="Complete Booking"><i class="fas fa-check-circle"></i> Done</button>
                </div>
            </div>
        </div>
    </div>
    <!-- end schedule details view modal -->

    <!-- start customer modal -->
    <div class="modal fade" id="modalAddCustomer" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputFormCustomer" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                Add Customer
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
                                    <label>Customer Name *</label>
                                    <input type="text" id="full_name" name="full_name" placeholder="Full name" required data-validation-required-message="Customer name is required" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                            <div class="col-md-5">
                                <div class="form-group control-group form-inline controls">
                                    <label>System User</label>
                                    <select name="user_id" id="user_id" class="form-control input-full">
                                    </select>
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>

                        <!-- <div class="form-group control-group form-inline controls">
                            <label>Customer Email *</label>
                            <input type="email" id="email" name="email" placeholder="email@example.com" required data-validation-required-message="Email address is required" class="form-control input-full" />
                            <span class="help-block"></span>
                        </div> -->

                        <div class="row">
                            <div class="col-md-7">
                                <div class="form-group control-group form-inline controls">

                                    <label class="col-md-12 p-0">Customer Phone *</label>
                                    <input type="tel" id="phone_no" maxlength="20" name="phone_no" placeholder="Phone Number" required data-validation-required-message="Phone number is required" class="form-control input-full w-100" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                            <div class="col-md-5">
                                <div class="form-group control-group form-inline controls">
                                    <label>Date of Birth </label>
                                    <input type="text" id="dob" name="dob" class="form-control input-full datePicker" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline ">
                            <label>Street Address *</label>
                            <textarea type="text" id="street_address" name="street_address" required data-validation-required-message="Street address is required" class="form-control input-full"></textarea>
                            <span class="help-block"></span>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline controls">
                                    <label>Country</label>
                                    <input type="text" id="country" name="country" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline controls">
                                    <label>City</label>
                                    <input type="text" id="city" name="city" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline controls">
                                    <label>State Name</label>
                                    <input type="text" id="state" name="state" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline controls">
                                    <label>Postal Code</label>
                                    <input type="number" id="postal_code" name="postal_code" class="form-control input-full" />
                                    <span class="help-block"></span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline controls">
                            <label>Remarks</label>
                            <input type="text" id="remarks" name="remarks" class="form-control input-full" />
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-success btn-sm">Save Change</button>

                    </div>
                </form>

            </div>
        </div>
    </div>
    <!-- end customer modal -->

</div>



@endsection