@extends('layouts.app')
@section('content')
<div class="page-inner">
    <div class="row">
        <div class="offset-md-2 col-md-8">
            <div class="main-card card">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate" enctype="multipart/form-data">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                <i class="fas fa-cog"></i> {{translate('Google Map Settings')}}
                            </h4>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Lat')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="number" value="{{$mapSettings->lat}}" id="lat" name="lat" required="required" class="form-control input-full" data-validation-required-message="Lat is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                        {{translate('Long')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="number" value="{{$mapSettings->long}}" id="long" name="long" required="required" class="form-control input-full" data-validation-required-message="Long is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                                {{translate('Map Key')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" value="{{$mapSettings->map_key}}" id="map_key" name="map_key" required="required" class=" form-control input-full" data-validation-required-message="Map key is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="submit" class="btn btn-success">{{translate('Save Change')}}</button>

                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

@push("adminScripts")
<script src="{{ dsAsset('js/custom/website/google-map.js') }}"></script>
@endpush

@endsection