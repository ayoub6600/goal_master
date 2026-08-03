@extends('layouts.app')
@section('content')

@push("adminScripts")
<script src="{{ dsAsset('js/lib/tui.calendar/tui-code-snippet/dist/tui-code-snippet.min.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.calendar/tui-time-picker/dist/tui-time-picker.min.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.calendar/tui-date-picker/dist/tui-date-picker.min.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.calendar/tui-calendar/dist/tui-calendar.min.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.calendar/tui-calendar-init.js') }}"></script>
<script src="{{ dsAsset('js/custom/settings/business-holiday.js') }}"></script>
@endpush

@push("adminCss")
<link href="{{ dsAsset('js/lib/tui.calendar/tui-calendar/dist/tui-calendar.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/tui.calendar/tui-time-picker/dist/tui-time-picker.min.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/tui.calendar/tui-date-picker/dist/tui-date-picker.min.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('css/custom/settings/business-holiday.css')}}" rel="stylesheet" />

@endpush




<div class="page-inner">
    <!--Modal-->
    <div class="modal fade tui-calender-modal" id="frmAddCalendarModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog tui-calendar-modal-content" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="inputFormCalendar" novalidate="novalidate">
                    <input type="hidden" name="id" id="id" />
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
                                <input id="title" name="title" class="tui-full-calendar-content w80" placeholder="{{translate('Subject')}}" value="" required>
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


    <!--datatable-->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <div class="row w100">
                            <div class=" col-md-4">
                                <h4 class="card-title">
                                    {{translate('Business Holiday')}}
                                </h4>
                            </div>
                            <div class="col-md-8">
                                <select id="cmn_branch_id" class="form-control"></select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body">
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
    </div>
</div>




@endsection