@extends('layouts.app')
@section('content')
<div class="page-inner">
    <div class="row">
        <div class="offset-md-1 col-md-10">
            <div class="main-card card">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                <i class="fas fa-cog"></i> {{translate('Business Hour Settings')}}
                            </h4>
                        </div>
                    </div>
                    <div id="topDivTblBusinessHour" class="w100 p-4">

                        <table id="tblBusinessHour" class="w100">
                            <tr>
                                <td class="p-2"><b>{{translate('Branch Name')}}<span class="required-label">*</span></b></td>
                                <td class="p-2" colspan="2">
                                    <select id="cmn_branch_id" name="cmn_branch_id" class="form-control input-full">
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="p-2">
                                    <label>{{translate('Sunday')}}</label>
                                    <input type="hidden" readonly value="0" name="business[0][day]" class="day form-control input-full" />
                                    <input type="hidden" name="business[0][id]" class="id form-control input-full" />
                                </td>
                                <td class="p-2"><input type="text" name="business[0][start_time]" required class="start_time form-control input-full" data-validation-required-message="Email address is required"></td>
                                <td class="p-2"><input type="text" name="business[0][end_time]" class="end_time form-control input-full"></td>
                                <td class="p-2">
                                    <label class="switch">
                                        <input name="business[0][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                        <span class="slider round"></span>
                                    </label>
                                    <label class="pt-1">{{translate('Is Weekly Holiday')}}</label>
                                </td>
                            </tr>
                            <tr>
                                <td class="p-2">
                                    <label>{{translate('Monday')}}</label>
                                    <input type="hidden" value="1" name="business[1][day]" class="day form-control input-full" />
                                    <input type="hidden" name="business[1][id]" class="id form-control input-full" />
                                </td>
                                <td class="p-2"><input type="text" name="business[1][start_time]" class="start_time form-control input-full"></td>
                                <td class="p-2"><input type="text" name="business[1][end_time]" class="end_time form-control input-full"></td>
                                <td class="p-2">
                                    <label class="switch">
                                        <input name="business[1][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                        <span class="slider round"></span>
                                    </label>
                                    <label class="pt-1">{{translate('Is Weekly Holiday')}}</label>
                                </td>
                            </tr>

                            <tr>
                                <td class="p-2">
                                    <label>{{translate('Tuesday')}}</label>
                                    <input type="hidden" value="2" name="business[2][day]" class="day form-control input-full" />
                                    <input type="hidden" name="business[2][id]" class="id form-control input-full" />
                                </td>
                                <td class="p-2"><input type="text" name="business[2][start_time]" class="start_time form-control input-full"></td>
                                <td class="p-2"><input type="text" name="business[2][end_time]" class="end_time form-control input-full"></td>
                                <td class="p-2">
                                    <label class="switch">
                                        <input name="business[2][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                        <span class="slider round"></span>
                                    </label>
                                    <label class="pt-1">{{translate('Is Weekly Holiday')}}</label>
                                </td>
                            </tr>

                            <tr>
                                <td class="p-2">
                                    <label>{{translate('Wednesday')}}</label>
                                    <input type="hidden" value="3" name="business[3][day]" class="day form-control input-full" />
                                    <input type="hidden" name="business[3][id]" class="id form-control input-full" />
                                </td>
                                <td class="p-2"><input type="text" name="business[3][start_time]" class="start_time form-control input-full"></td>
                                <td class="p-2"><input type="text" name="business[3][end_time]" class="end_time form-control input-full"></td>
                                <td class="p-2">
                                    <label class="switch">
                                        <input name="business[3][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                        <span class="slider round"></span>
                                    </label>
                                    <label class="pt-1">{{translate('Is Weekly Holiday')}}</label>
                                </td>
                            </tr>

                            <tr>
                                <td class="p-2">
                                    <label>{{translate('Thursday')}}</label>
                                    <input type="hidden" value="4" name="business[4][day]" class="day form-control input-full" />
                                    <input type="hidden" name="business[4][id]" class="id form-control input-full" />
                                </td>
                                <td class="p-2"><input type="text" name="business[4][start_time]" class="start_time form-control input-full"></td>
                                <td class="p-2"><input type="text" name="business[4][end_time]" class="end_time form-control input-full"></td>
                                <td class="p-2">
                                    <label class="switch">
                                        <input name="business[4][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                        <span class="slider round"></span>
                                    </label>
                                    <label class="pt-1">{{translate('Is Weekly Holiday')}}</label>
                                </td>
                            </tr>

                            <tr>
                                <td class="p-2">
                                    <label>{{translate('Friday')}}</label>
                                    <input type="hidden" value="5" name="business[5][day]" class="day form-control input-full" />
                                    <input type="hidden" name="business[5][id]" class="id form-control input-full" />
                                </td>
                                <td class="p-2"><input type="text" name="business[5][start_time]" class="start_time form-control input-full"></td>
                                <td class="p-2"><input type="text" name="business[5][end_time]" class="end_time form-control input-full"></td>
                                <td class="p-2">
                                    <label class="switch">
                                        <input name="business[5][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                        <span class="slider round"></span>
                                    </label>
                                    <label class="pt-1">{{translate('Is Weekly Holiday')}}</label>
                                </td>
                            </tr>

                            <tr>
                                <td class="p-2">
                                    <label>{{translate('Saturday')}}</label>
                                    <input type="hidden" value="6" name="business[6][day]" class="day form-control input-full">
                                    <input type="hidden" name="business[6][id]" class="id form-control input-full">
                                </td>
                                <td class="p-2"><input type="text" name="business[6][start_time]" class="start_time form-control input-full"></td>
                                <td class="p-2"><input type="text" name="business[6][end_time]" class="end_time form-control input-full"></td>
                                <td class="p-2">
                                    <label class="switch">
                                        <input name="business[6][is_off_day]" type="checkbox" value="1" class="is_off_day rm-slider" />
                                        <span class="slider round"></span>
                                    </label>
                                    <label class="pt-1">{{translate('Is Weekly Holiday')}}</label>
                                </td>
                            </tr>




                        </table>

                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-success">{{translate('Save Change')}}</button>

                    </div>
            </div>
            </form>
        </div>
    </div>
</div>
</div>
@push("adminScripts")
<script src="{{ dsAsset('js/custom/settings/business-hour.js') }}"></script>
@endpush
@push("adminCss")
<link href="{{ dsAsset('css/custom/settings/business-hour.css')}}" rel="stylesheet" />
@endpush
@endsection