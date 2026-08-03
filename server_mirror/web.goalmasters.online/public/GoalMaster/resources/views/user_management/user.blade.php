@extends('layouts.app')
@section('content')
@push("adminScripts")
<script>
    var isAdmin = "{{$isAdmin}}";
</script>
      <script src="{{ dsAsset('js/custom/user_management/user.js') }}"></script>  
@endpush

<div class="page-inner">
    <!--Modal-->
    <div class="modal fade" id="frmUserModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <form class="form-horizontal" id="userForm" novalidate="novalidate">

                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="fw-mediumbold">
                                {{translate('User Info')}}
                            </span>
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">


                        <!-- <div class="form-group form-inline control-group">
                            <label for="email" class="col-md-3 col-form-label">
                                {{translate('Email Address')}}
                                <span class="required-label"> *</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="email" id="email" name="email" class="form-control input-full"
                                    placeholder="{{translate('Email address')}}" required="required"
                                    data-validation-required-message="Valid Email address is required" />
                                <span class="help-block"></span>
                            </div>
                        </div> -->

                        <div class="form-group control-group form-inline ">
                            <label class="col-md-3">
                                {{translate('User Name')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="text" id="username" name="username" placeholder="{{translate('User name')}}" required
                                    class="form-control input-full"
                                    data-validation-required-message="User Name is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline">
                            <label class="col-md-3 col-form-label">
                                {{translate('الاسم كاملا')}}
                                <span class="required-label"> *</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="text" id="name" name="name" class="form-control input-full"
                                    placeholder="{{translate('Full Name')}}" required
                                    data-validation-required-message="User Full Name is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="div-password form-group control-group form-inline">
                            <label class="col-md-3 col-form-label">
                                {{translate('Password')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="password" name="password" id="password" placeholder="{{translate('Password')}}"
                                    class="form-control input-full" required minlength="8"
                                    data-validation-required-message="Password is required" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="div-password form-group control-group form-inline">
                            <label class="col-md-3 col-form-label">
                                {{translate('Confirm Password')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="password" name="password_confirmation" id="password_confirmation"
                                    placeholder="{{translate('Confirm Password')}}" class="form-control input-full" required minlength="8"
                                    data-validation-required-message="Confirm password is required"
                                    data-validation-match-match="password" />
                                <span class="help-block"></span>
                            </div>
                        </div>
                        @if ($isSystemUser)

                        <div class="form-group control-group form-inline">
                            <!-- <div class="col-md-3 controls"> -->
                                <label for="phone_no" class="col-md-3 col-form-label">{{translate('Phone Number')}}
                                <span class="required-label"> *</span>
                                </label>
                            <!-- </div> -->
                                <div class="col-md-9 controls">

                                    <input id="phone_no" type="number" 
                                    class="form-control input-full @error('phone_no') is-invalid @enderror" 
                                    placeholder="{{translate('Phone Number')}}" 
                                    name="phone_no" value="{{ old('phone_no') }}"  
                                    autocomplete="phone_no" autofocus 
                                    />
                                    @error('phone_no')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                    @enderror
                                </div>
                        </div>
                        
                        <div class="form-group control-group form-inline">
                            <label class="col-md-3 col-form-label">
                                {{translate('User Type')}}
                                <span class="required-label"> *</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="hidden" id="userType" name="userType" class="form-control input-full"
                                value='WebUser'  required data-validation-required-message="User Role is required"  >
                                    </input> 
                                    <input class="form-control input-full" placeholder="Web User"  disabled>
                                    </input>                                
                                <span class="help-block"></span>
                            </div>
                        </div>

                        @else


                        <div class="form-group control-group form-inline">
                                <label class="col-md-3 col-form-label">
                                    {{translate('User Type')}}        
                                </label>
                                <div class="col-md-9 controls">
                                    <select id="userType" name="userType" class="form-control input-full">
                                        <option value="">{{translate('Select One')}}</option>
                                        <option value="1">{{translate('System User')}}</option>
                                        <option value="WebUser">{{translate('Web User')}}</option>
                                    </select>                                
                                    <span class="help-block"></span>
                                </div>
                        </div>

                        <div class="d-none" id="system_user">

                            <div class="form-group control-group form-inline">
                                <label class="col-md-3 col-form-label">
                                    {{translate('User Role')}}
                                    <span class="required-label"> *</span>
                                </label>
                                <div class="col-md-9 controls">
                                    <select id="sec_role_id" name="sec_role_id" class="form-control input-full"
                                        placeholder="User Role" ></select>                                
                                    <span class="help-block"></span>
                                </div>
                            </div>
    
                            <!-- <div class="form-group control-group form-inline d-none" id="branchAndEmployee"> -->
    
                                <div class="form-group control-group form-inline">
                                    <label class="col-md-3 col-form-label">
                                        {{translate('User Branch')}}        
                                    </label>
                                    <div class="col-md-9 controls">
                                        <select id="cmn_branch_id" name="cmn_branch_id" class="form-control input-full" 
                                        
                                        multiple></select>                                
                                        <span class="help-block"></span>
                                    </div>
                                </div>
                                <!-- <div class="form-group control-group form-inline">
                                    <label class="col-md-3 col-form-label">
                                        {{translate('Staff/Employee')}}        
                                    </label>
                                    <div class="col-md-9 controls">
                                        <select id="sch_employee_id" name="sch_employee_id" class="form-control input-full" data-live-search="true"></select>                                
                                        <span class="help-block"></span>
                                    </div>
                                </div> -->
                            <!-- </div> -->
    
                            <div class="form-group form-inline">
                                <label class="col-md-3 col-form-label">{{translate('Status')}}</label>
                                <div class="col-md-9">
                                    <div class="form-check">
                                        <label class="form-radio-label">
                                            <input id="statusYes" type="radio" name="status" class="form-radio-input" value="1" checked="checked" />
                                            <span class="form-radio-sign pl-1"> {{translate('Active')}}</span>
                                        </label>
                                        <label class="form-radio-label">
                                            <input id="statusNo" type="radio" class="form-radio-input" name="status"
                                                value="0" />
                                            <span class="form-radio-sign pl-1"> {{translate('Inactive')}}</span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        
                        </div>


                        <div class="d-none" id="web_user">

                        
                            <div class="form-group control-group form-inline">
                                <!-- <div class="col-md-3 controls"> -->
                                    <label for="phone_no" class="col-md-3 col-form-label">{{translate('Phone Number')}}
                                    <span class="required-label"> *</span>
                                    </label>
                                <!-- </div> -->
                                    <div class="col-md-9 controls">
    
                                        <input id="phone_no" type="number" 
                                        class="form-control input-full " 
                                        placeholder="{{translate('Phone Number')}}" 
                                        name="phone_no" value="{{ old('phone_no') }}"/>

                                    </div>
                            </div>
                            

    
                        </div>

                        @endif

                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">{{translate('Close')}}</button>
                        <button type="submit" id="btnSave" class="btn btn-primary btn-sm">{{translate('Save Change')}}</button>

                    </div>
                </form>

            </div>
        </div>
    </div>

  

    
    <!-- Add Balance Modal -->
    <div class="modal fade" id="addBalanceModal" tabindex="-1" role="dialog" aria-labelledby="addBalanceModalLabel" aria-hidden="true" >
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header" dir="rtl">
            <h5 class="modal-title" id="addBalanceModalLabel">{{translate('Add Balance')}}</h5>
            <button type="button" class="close m-0 p-0" data-dismiss="modal" aria-label="Close" >
              <span aria-hidden="true" >&times;</span>
            </button>
          </div>
          <form id="addBalanceForm">
            <div class="modal-body" dir="rtl">
              <input type="hidden" id="userId" name="userId" value="">
              <div class="form-group">
                <label for="balanceAmount" class="float-right">{{translate('Balance Amount')}}</label>
                <input type="number" class="form-control" id="balanceAmount" name="balanceAmount" placeholder="{{translate('Enter amount')}}" required>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Close')}}</button>
              <button type="submit" class="btn btn-primary">{{translate('Add Balance')}}</button>
            </div>
          </form>
        </div>
      </div>
    </div>


    


    <!--User datatable-->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title"> <i class="fas fa-user"></i> {{translate('User Information')}} </h4>
                        <button id="btnAddUser" class="btn btn-primary btn-sm btn-round ml-auto">
                            <i class="fa fa-plus"></i> {{translate('Add New User')}}
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
