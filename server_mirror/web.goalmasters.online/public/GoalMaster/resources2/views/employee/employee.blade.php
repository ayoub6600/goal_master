@extends('layouts.app')
@section('content')
@push("adminCss")
<link href="{{ dsAsset('js/lib/tui.calendar/tui-calendar/dist/tui-calendar.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/tui.calendar/tui-time-picker/dist/tui-time-picker.min.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/tui.calendar/tui-date-picker/dist/tui-date-picker.min.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('css/custom/employee/employee.css')}}" rel="stylesheet" />
@endpush

@push("adminScripts")
<script src="{{ dsAsset('js/lib/tui.calendar/tui-code-snippet/dist/tui-code-snippet.min.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.calendar/tui-time-picker/dist/tui-time-picker.min.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.calendar/tui-date-picker/dist/tui-date-picker.min.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.calendar/tui-calendar/dist/tui-calendar.min.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.calendar/tui-calendar-init.js') }}"></script>
<script src="{{ dsAsset('js/lib/country-list.js') }}"></script>
<script src="{{ dsAsset('js/custom/employee/employee.js') }}"></script>
@endpush



<div class="page-inner">
    <!--Modal-->
    <div class="modal fade tui-calender-modal" id="frmAddCalendarModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog tui-calendar-modal-content" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputFormOffDay" novalidate="novalidate">
                    <input type="hidden" name="id" id="calId" />
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Add or update off day')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">

                        <div class="form-group control-group form-inline">
                            <div class="tui-full-calendar-popup-section-item w100">
                                <span class="tui-full-calendar-icon tui-full-calendar-ic-title"></span>
                                <input id="holiday-title" name="title" class="tui-full-calendar-content w80" placeholder="{{translate('Subject')}}" value="" required>
                            </div>

                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline">
                                    <div class="tui-full-calendar-popup-section-item w100">
                                        <span class="tui-full-calendar-icon tui-full-calendar-ic-date"></span>
                                        <input id="start-date" name="start_date" class="startDate tui-full-calendar-content w80" placeholder="{{translate('Start date')}}" required>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group control-group form-inline">
                                    <div class="tui-full-calendar-popup-section-item w100">
                                        <span class="tui-full-calendar-icon tui-full-calendar-ic-date"></span>
                                        <input id="end-date" name="end_date" class="endDate tui-full-calendar-content w80" placeholder="{{translate('End date')}}" required>
                                    </div>
                                </div>
                            </div>
                        </div>


                    </div>
                    <div class="modal-footer">
                        <button type="submit" id="btn-calendar-save" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>

                    </div>
                </form>

            </div>
        </div>
    </div>

    <!-- details view modal -->
    <div class="modal fade tui-calender-modal" id="frmViewCalendarModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog tui-calendar-modal-content" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div id="divScheduleDetails"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" id="btn-calendar-edit" class="btn btn-warning btn-sm float-left">{{translate('Edit')}}</button>
                    <button type="button" id="btn-calendar-delete" class="btn btn-danger btn-sm">{{translate('Delete')}}</button>

                </div>
            </div>
        </div>
    </div>
    <!-- end details view modal -->

    <div class="modal fade" id="frmModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputForm" enctype="multipart/form-data">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('Staff / Employee Info')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <nav>
                            <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                <a class="nav-link active" id="nav-profile-tab" data-toggle="tab" href="#nav-profile" role="tab" aria-controls="nav-profile" aria-selected="true"><i class="far fa-user"></i> {{translate('Basic Profile')}}</a>
                                <a class="nav-link" id="nav-service-tab" data-toggle="tab" href="#nav-service" role="tab" aria-controls="nav-service" aria-selected="false"><i class="fas fa-th fa-fw"></i> {{translate('Available Service')}}</a>
                                <a class="nav-link" id="nav-schedule-tab" data-toggle="tab" href="#nav-schedule" role="tab" aria-controls="nav-schedule" aria-selected="false"><i class="far fa-calendar-alt"></i> {{translate('Service Time')}}</a>
                                <a class="nav-link" id="nav-offday-tab" data-toggle="tab" href="#nav-offday" role="tab" aria-controls="nav-offday" aria-selected="false"><i class="far fa-calendar"></i> {{translate('Day Off')}}</a>
                            </div>
                        </nav>
                        <div class="tab-content" id="nav-tabContent">
                            <input type="hidden" name="id" id="id" />


                            <!-- Profile -->
                            <div class="tab-pane fade show active" id="nav-profile" role="tabpanel" aria-labelledby="nav-profile-tab">
                                <div class="row">
                                    <div class="col-md-4 pl-4">
                                        <div class="form-group control-group form-inline">
                                            <img id="empimagepreview" width="100%" />
                                            <span class="float-left w-100">{{translate('Image')}} 360x260</span>
                                            <input class="mt-1" type="file" id="image_url" name="image_url" accept="image/png, image/jpeg">
                                        </div>
                                    </div>
                                    <div class="col-md-8">
                                        <div class="form-group control-group form-inline">
                                            <label class="col-md-12">
                                                {{translate('Staff Name')}}
                                                <span class="required-label">*</span>
                                            </label>
                                            <div class="col-md-12 controls">
                                                <input type="text" id="full_name" name="full_name" required placeholder="{{translate('Staff/Employee Name')}}" class="form-control input-full" data-validation-required-message="Staff/Employee Name is required" />
                                                <span class="help-block"></span>
                                            </div>
                                        </div>
                                        <div class="form-group control-group form-inline">
                                            <label class="col-md-12">
                                                {{translate('Staff ID')}} <span class="required-label">*</span>
                                            </label>
                                            <div class="col-md-12 controls">
                                                <input type="text" id="employee_id" name="employee_id" placeholder="{{translate('Staff/Employee ID')}}" class="form-control input-full" />
                                                <span class="help-block"></span>
                                            </div>
                                        </div>
                                        <div class="form-group control-group form-inline">
                                            <label class="col-md-12">
                                                {{translate('Branch')}}
                                                <span class="required-label">*</span>
                                            </label>
                                            <div class="col-md-12 controls">
                                                <select id="cmn_branch_id" name="cmn_branch_id" class="form-control input-full" required data-validation-required-message="Branch is required"></select>
                                                <span class="help-block"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>


                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group form-inline control-group">
                                            <label class="col-md-12">
                                                {{translate('Phone No')}}
                                            </label>
                                            <div class="col-md-12 controls">
                                                <div class="input-group">
                                                    <input type="text" id="contact_no" maxlength="20" placeholder="{{translate('Phone No')}}" class="form-control w100" />
                                                </div>
                                                <span class="help-block"></span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group control-group form-inline ">
                                            <label class="col-md-12">
                                                {{translate('Email Address')}}
                                                <span class="required-label">*</span>
                                            </label>
                                            <div class="col-md-12 controls">
                                                <input type="email" id="email_address" name="email_address" placeholder="{{translate('Email Address')}}" class="form-control input-full" required data-validation-required-message="Email is required" />
                                                <span class="help-block"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group control-group form-inline">
                                    <!-- <div class="col-md-6">
                                        <div class="row">
                                            <label class="col-md-12">
                                                {{translate('Department')}}
                                            </label>
                                            <div class="col-md-12 controls">
                                                <select id="hrm_department_id" name="hrm_department_id" class="form-control input-full"></select>
                                                <span class=" help-block"></span>
                                            </div>
                                        </div>
                                    </div> -->


                                    <div class="col-md-12 ">
                                        <div class="row">
                                            <label class="col-md-12">
                                                {{translate('Designation')}}
                                                <span class="required-label">*</span>
                                            </label>
                                            <div class="col-md-12 controls">
                                                <select id="hrm_designation_id" name="hrm_designation_id" class="form-control input-full" required data-validation-required-message="Designation is required"></select>
                                                <span class="help-block"></span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group control-group form-inline">
                                        <div class="col-md-6 " style="display: none;">
                                            <div class="row">
                                                <label class="col-md-12">
                                                    {{translate('Salary')}}
                                                </label>
                                                <div class="col-md-12 controls">
                                                    <input type="number" name="salary" id="salary" placeholder="{{translate('Monthly Salary')}}" class="form-control input-full" value="0.00" />
                                                    <span class=" help-block"></span>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-md-6 " style="display: none;">
                                            <div class="row">
                                                <label class="col-md-12">
                                                    {{translate('Commission per service')}} %
                                                </label>
                                                <div class="col-md-12 controls">
                                                    <input type="number" name="commission" id="commission" placeholder="{{translate('Commission per service')}}" class="form-control input-full" value="0.00" />
                                                    <span class="help-block"></span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                <div class="form-group control-group form-inline">
                                    <div class="col-md-6 " style="display: none;">
                                        <div class="row">
                                            <label class="col-md-12">
                                                {{translate('Commission based on')}}
                                            </label>
                                            <div class="col-md-12 controls">
                                                <select id="pay_commission_based_on" name="pay_commission_based_on" class="form-control input-full">
                                                    <option value="1">Salary</option>
                                                    <option value="2">Service Amount</option>
                                                </select>
                                                <span class="help-block"></span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6 " style="display: none;">
                                        <div class="row">
                                            <label class="col-md-12">
                                                {{translate('Target service amount')}}
                                            </label>
                                            <div class="col-md-12 controls">
                                                <input type="number" name="target_service_amount" id="target_service_amount" placeholder="{{translate('service')}}" class="form-control input-full" value="0.00" readonly="true" />
                                                <span class="help-block"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group control-group form-inline " style="display: none;">
                                    <label class="col-md-12">
                                        {{translate('System User')}}
                                    </label>
                                    <div class="col-md-12 controls">
                                        <select id="user_id" name="user_id" class="form-control input-full"></select>
                                        <span class="help-block"></span>
                                    </div>
                                </div>



                            </div>
                            
                            <div class="form-group control-group form-inline ">
                                    <label class="col-md-12">
                                        {{translate('Gender')}} <span class="required-label">*</span>
                                    </label>
                                    <div class="col-md-12 controls">
                                        <select id="gender" name="gender" class="form-control input-full">
                                            <option value="1">ملعب</option>
                                            <option value="2">منتج</option>
                                            <option value="3">غير ذلك</option>
                                        </select>
                                        <span class="help-block"></span>
                                    </div>
                                </div>

                                <div class="form-group control-group form-inline ">
                                    <label class="col-md-12">
                                        {{translate('Visibility Status')}}
                                        <span class="required-label">*</span>
                                    </label>
                                    <div class="col-md-12 controls">
                                        <select id="status" name="status" class="form-control input-full">
                                            <option value="1">نشر</option>
                                            <option value="2">خاص</option>
                                            <option value="3">اخفاء</option>
                                        </select>
                                        <span class="help-block"></span>
                                    </div>
                                </div>

                        </div>
                                
<div class="form-group control-group form-inline " style="display: none;">
    <label class="col-md-12">
        {{translate('Date Of Birth')}}
    </label>
    <div class="col-md-12 controls">
        <input type="text" id="dob" name="dob" placeholder="yyyy-mm-dd" class="datePicker form-control input-full" />
        <span class="help-block"></span>
    </div>
</div>

<div class="form-group control-group form-inline " style="display: none;">
    <label class="col-md-12">
        {{translate('Specialist')}}
    </label>
    <div class="col-md-12 controls">
        <textarea type="text" id="specialist" name="specialist" placeholder="{{translate('Specialist')}}" class="form-control input-full"></textarea>
        <span class="help-block"></span>
    </div>
</div>

<div class="form-group control-group form-inline " style="display: none;">
    <label class="col-md-12">
        {{translate('Present Address')}}
    </label>
    <div class="col-md-12 controls">
        <textarea type="text" id="present_address" name="present_address" placeholder="{{translate('Present Address')}}" class="form-control input-full"></textarea>
        <span class="help-block"></span>
    </div>
</div>

<div class="form-group control-group form-inline " style="display: none;">
    <label class="col-md-12">
        {{translate('Permanent Address')}}
    </label>
    <div class="col-md-12 controls">
        <textarea type="text" id="permanent_address" name="permanent_address" placeholder="{{translate('Permanent Address')}}" class="form-control input-full"></textarea>
        <span class="help-block"></span>
    </div>
</div>

<div class="form-group control-group form-inline " style="display: none;">
    <label class="col-md-12">
        {{translate('Note')}}
    </label>
    <div class="col-md-12 controls">
        <textarea type="text" id="note" name="note" placeholder="{{translate('Note')}}" class="form-control input-full"></textarea>
        <span class="help-block"></span>
    </div>
</div>

<div class="form-group control-group form-inline " style="display: none;">
    <label class="col-md-12">
        {{translate('ID Card')}}
    </label>
    <div class="col-md-12 controls">
        <input type="file" id="id_card" name="id_card" accept="image/png, image/jpeg">
        <div class="float-left w-100">
            <img id="empidcardimageview" class="mw250px" />
        </div>
    </div>
</div> <!-- إغلاق div المفتوح سابقاً -->

<div class="form-group control-group form-inline " style="display: none;">
    <label class="col-md-12">
        {{translate('Passport')}}
    </label>
    <div class="col-md-12 controls">
        <input type="file" id="passport" name="passport" accept="image/png, image/jpeg">
        <div class="float-left w-100">
            <img id="emppassportimageview" class="mw250px" />
        </div>
    </div>
</div>


<!-- إغلاق div الأساسي بعد إصلاح المشاكل -->

                            <!-- end profile -->

                            <!-- Service -->
                            <div class="tab-pane fade" id="nav-service" role="tabpanel" aria-labelledby="nav-service-tab">
                                <div class="row div-service">
                                    <div class="col-md-12">
                                        <ul id="ul-employee-service">
                                        </ul>
                                    </div>
                                </div>
                            </div>
                            <!-- End Service -->

                            <!-- Schedule -->
                            <div class="tab-pane fade" id="nav-schedule" role="tabpanel" aria-labelledby="nav-schedule-tab">
                                <div class="w100 mt-2" id="topDivTblEmployeeSchedule">
                                    <table class="w100" id="tblEmployeeSchedule">
                                        <thead>
                                            <tr class="text-center">
                                                <th>{{translate('Day')}}</th>
                                                <th>{{translate('Start Time')}}</th>
                                                <th>{{translate('End Time')}}</th>
                                                <!-- <th>{{translate('Break Start')}}</th> -->
                                                <!-- <th>{{translate('Break End')}}</th> -->
                                                <th>{{translate('Weekly Holiday')}}</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td class="p-2">
                                                    <label>{{translate('Sunday')}}</label>
                                                    <input type="hidden" readonly value="0" name="business[0][day]" class="day form-control input-full" />
                                                    <input type="hidden" name="business[0][id]" class="id form-control input-full" />
                                                </td>
                                                <td class="p-2"><input type="text" required name="business[0][start_time]" class="start_time form-control input-full"></td>
                                                <td class="p-2"><input type="text" required name="business[0][end_time]" class="end_time form-control input-full"></td>
                                                <!-- <td class="p-2"><input type="text" required name="business[0][break_start_time]" class="break_start_time form-control input-full"></td> -->
                                                <!-- <td class="p-2"><input type="text" required name="business[0][break_end_time]" class="break_end_time form-control input-full"></td> -->
                                                <td class="p-2">
                                                    <label class="switch">
                                                        <input id="is_off_day" name="business[0][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                                        <span class="slider round"></span>
                                                    </label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="p-2">
                                                    <label>{{translate('Monday')}}</label>
                                                    <input type="hidden" value="1" name="business[1][day]" class="day form-control input-full" />
                                                    <input type="hidden" name="business[1][id]" class="id form-control input-full" />
                                                </td>
                                                <td class="p-2"><input type="text" required name="business[1][start_time]" class="start_time form-control input-full"></td>
                                                <td class="p-2"><input type="text" required name="business[1][end_time]" class="end_time form-control input-full"></td>
                                                <!-- <td class="p-2"><input type="text" required name="business[1][break_start_time]" class="break_start_time form-control input-full"></td> -->
                                                <!-- <td class="p-2"><input type="text" required name="business[1][break_end_time]" class="break_end_time form-control input-full"></td> -->
                                                <td class="p-2">
                                                    <label class="switch">
                                                        <input id="is_off_day" name="business[1][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                                        <span class="slider round"></span>
                                                    </label>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td class="p-2">
                                                    <label>{{translate('Tuesday')}}</label>
                                                    <input type="hidden" value="2" name="business[2][day]" class="day form-control input-full" />
                                                    <input type="hidden" name="business[2][id]" class="id form-control input-full" />
                                                </td>
                                                <td class="p-2"><input type="text" required name="business[2][start_time]" class="start_time form-control input-full"></td>
                                                <td class="p-2"><input type="text" required name="business[2][end_time]" class="end_time form-control input-full"></td>
                                                <!-- <td class="p-2"><input type="text" required name="business[2][break_start_time]" class="break_start_time form-control input-full"></td> -->
                                                <!-- <td class="p-2"><input type="text" required name="business[2][break_end_time]" class="break_end_time form-control input-full"></td> -->
                                                <td class="p-2">
                                                    <label class="switch">
                                                        <input id="is_off_day" name="business[2][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                                        <span class="slider round"></span>
                                                    </label>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td class="p-2">
                                                    <label>{{translate('Wednesday')}}</label>
                                                    <input type="hidden" value="3" name="business[3][day]" class="day form-control input-full" />
                                                    <input type="hidden" name="business[3][id]" class="id form-control input-full" />
                                                </td>
                                                <td class="p-2"><input type="text" required name="business[3][start_time]" class="start_time form-control input-full"></td>
                                                <td class="p-2"><input type="text" required name="business[3][end_time]" class="end_time form-control input-full"></td>
                                                <!-- <td class="p-2"><input type="text" required name="business[3][break_start_time]" class="break_start_time form-control input-full"></td> -->
                                                <!-- <td class="p-2"><input type="text" required name="business[3][break_end_time]" class="break_end_time form-control input-full"></td> -->
                                                <td class="p-2">
                                                    <label class="switch">
                                                        <input id="is_off_day" name="business[3][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                                        <span class="slider round"></span>
                                                    </label>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td class="p-2">
                                                    <label>{{translate('Thursday')}}</label>
                                                    <input type="hidden" value="4" name="business[4][day]" class="day form-control input-full" />
                                                    <input type="hidden" name="business[4][id]" class="id form-control input-full" />
                                                </td>
                                                <td class="p-2"><input type="text" required name="business[4][start_time]" class="start_time form-control input-full"></td>
                                                <td class="p-2"><input type="text" required name="business[4][end_time]" class="end_time form-control input-full"></td>
                                                <!-- <td class="p-2"><input type="text" required name="business[4][break_start_time]" class="break_start_time form-control input-full"></td> -->
                                                <!-- <td class="p-2"><input type="text" required name="business[4][break_end_time]" class="break_end_time form-control input-full"></td> -->
                                                <td class="p-2">
                                                    <label class="switch">
                                                        <input id="is_off_day" name="business[4][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                                        <span class="slider round"></span>
                                                    </label>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td class="p-2">
                                                    <label>{{translate('Friday')}}</label>
                                                    <input type="hidden" value="5" name="business[5][day]" class="day form-control input-full" />
                                                    <input type="hidden" name="business[5][id]" class="id form-control input-full" />
                                                </td>
                                                <td class="p-2"><input type="text" required name="business[5][start_time]" class="start_time form-control input-full"></td>
                                                <td class="p-2"><input type="text" required name="business[5][end_time]" class="end_time form-control input-full"></td>
                                                <!-- <td class="p-2"><input type="text" required name="business[5][break_start_time]" class="break_start_time form-control input-full"></td> -->
                                                <!-- <td class="p-2"><input type="text" required name="business[5][break_end_time]" class="break_end_time form-control input-full"></td> -->
                                                <td class="p-2">
                                                    <label class="switch">
                                                        <input id="is_off_day" name="business[5][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                                        <span class="slider round"></span>
                                                    </label>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td class="p-2">
                                                    <label>{{translate('Saturday')}}</label>
                                                    <input type="hidden" value="6" name="business[6][day]" class="day form-control input-full">
                                                    <input type="hidden" name="business[6][id]" class="id form-control input-full">
                                                </td>
                                                <td class="p-2"><input type="text" required name="business[6][start_time]" class="start_time form-control input-full"></td>
                                                <td class="p-2"><input type="text" required name="business[6][end_time]" class="end_time form-control input-full"></td>
                                                <!-- <td class="p-2"><input type="text" required name="business[6][break_start_time]" class="break_start_time form-control input-full"></td> -->
                                                <!-- <td class="p-2"><input type="text" required name="business[6][break_end_time]" class="break_end_time form-control input-full"></td> -->
                                                <td class="p-2">
                                                    <label class="switch">
                                                        <input id="is_off_day" name="business[6][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                                        <span class="slider round"></span>
                                                    </label>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>

                                </div>
                            </div>
                            <!-- End Schedule -->

                            <!-- offday -->
                            <div class="tab-pane fade" id="nav-offday" role="tabpanel" aria-labelledby="nav-offday-tab">
                                <div class="row">
                                    <div class="col-md-12 mt-2">
                                        <div id="menu">
                                            <span id="menu-navi">
                                                <button type="button" class="btn btn-default2 btn-tui-calendar-default2 btn-sm move-today btn-round btn-move-calendar" data-action="move-today">{{translate('Today')}}</button>
                                                <button type="button" class="btn btn-default2 btn-tui-calendar-default2 btn-sm move-day btn-round btn-move-calendar" data-action="move-prev">
                                                    <i class="calendar-icon fas fa-chevron-left" data-action="move-prev"></i>
                                                </button>
                                                <button type="button" class="btn btn-default2 btn-tui-calendar-default2 btn-sm move-day btn-round btn-move-calendar" data-action="move-next">
                                                    <i class="calendar-icon fas fa-chevron-right" data-action="move-next"></i>
                                                </button>
                                            </span>
                                            <span id="renderRange" class="render-range"></span>
                                        </div>
                                        <div class="mt-1" id="calendar"></div>

                                    </div>
                                </div>
                            </div>
                            <!-- end offday -->

                        </div>


                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">{{translate('Close')}}</button>
                        <button type="submit" id="btnSaveEmployee" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>

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
                            {{translate('Staff Info')}}
                        </h4>
                        <button id="btnAdd" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New Staff')}}
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