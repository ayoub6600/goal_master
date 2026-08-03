@extends('layouts.app')
@section('content')
<div class="page-inner">
    
    <!--Change Profile photos-->
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            <i class="fas fa-user-circle"></i> {{translate('Change Profile Photo')}}
                        </h4>
                    </div>
                </div>
                <div class="card-body">
                    <form class="form-horizontal" method="post" action="{{ route('update.user.profile.photo') }}" enctype="multipart/form-data">
                        @csrf
                        <div class="form-group control-group form-inline">
                            <label class="col-md-3 col-form-label">
                                {{translate('Profile Photo')}}
                                <span class="required-label">*</span>
                            </label>
                            <div class="col-md-9 controls">
                                <input type="file" name="profilePhoto" id="profilePhoto" class="form-control input-full" required
                                    accept="image/png,image/jpeg,image/jpg" />
                                <span class="help-block"></span>
                            </div>
                        </div>

                        <div class="form-group control-group form-inline">
                            <div class="offset-md-3 col-md-9">
                                @if($profilePhoto!=null || $profilePhoto!="")
                                <img width="150" src="{{dsAsset($profilePhoto)}}" />
                                @else
                                <img width="150" src="{{dsAsset('js/lib/assets/img/avater-man.png')}}" />
                                @endif
                            </div>
                        </div>

                        <div class="div-password form-group control-group form-inline">
                            <div class="col-md-12">
                                <input type="submit" id="btnChangePhoto" class="btn btn-success btn-sm pull-right" value="{{translate('Save Change')}}" />
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@push("adminScripts")
<script src="{{ dsAsset('js/custom/user_management/change-password.js') }}"></script>
@endpush



@endsection
