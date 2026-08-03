@extends('layouts.app')
@section('content')
@push("adminScripts")
<script src="{{ dsAsset('js/lib/color-picker-coloris/coloris.min.js') }}"></script>
<script src="{{ dsAsset('js/custom/website/appearance.js') }}"></script>
@endpush
@push("adminCss")
<link href="{{ dsAsset('js/lib/color-picker-coloris/coloris.min.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('css/custom/website/appearance.css') }}" rel="stylesheet" />
@endpush




<div class="page-inner">
    <div class="row">
        <div class="offset-md-2 col-md-8">
            <div class="main-card card">
                <form class="form-horizontal" id="inputForm" novalidate="novalidate" enctype="multipart/form-data">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                <i class="fas fa-cog"></i> {{translate('General Settings')}}
                            </h4>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('App Name')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" value="{{$appearance->app_name}}" id="app_name" name="app_name" placeholder="{{translate('Example')}}" required="required" class="form-control input-full" data-validation-required-message="App name is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Website Motto')}}
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" value="{{$appearance->motto}}" id="motto" name="motto"  class="form-control input-full" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Theam Color')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls square">
                            <input type="text" value="{{$appearance->theam_color}}" id="theam_color" name="theam_color" placeholder="#c725c3" required="required" class="coloris squire form-control input-full" data-validation-required-message="Theam color is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Page Menu Color')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls square">
                            <input type="text" value="{{$appearance->theam_menu_color2}}" id="theam_menu_color2" name="theam_menu_color2" placeholder="#c725c3" required="required" class="                                                    form-control input-full" data-validation-required-message="Page menu color is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Theam Hover Color')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls square">
                            <input type="text" value="{{$appearance->theam_hover_color}}" id="theam_hover_color" name="theam_hover_color" placeholder="#c725c3" required="required" class="coloris form-control input-full" data-validation-required-message="Theam hover color is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>


                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Theam Active Color')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls square">
                            <input type="text" value="{{$appearance->theam_active_color}}" id="theam_active_color" name="theam_active_color" placeholder="#c725c3" required="required" class="coloris form-control input-full" data-validation-required-message="Website nav hover color is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>


                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('About Service')}}
                        </label>
                        <div class="col-md-9 controls">
                            <textarea rows="4" id="about_service" maxlength="300" name="about_service" class="form-control input-full">{{$appearance->about_service}}</textarea>
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Icon 32x32')}}
                        </label>
                        <div class="col-md-9 controls">
                            <div class="w-100 float-left pb-2">
                                <img id="icon-view" width="64" height="64" class="float-left" src="{{$appearance->icon}}" />
                            </div>
                            <input type="file" id="icon" name="icon" accept=".ico" />
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Logo 212x60')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <div class="w-100 float-left pb-2">
                                <img id="logo-view" width="190" height="60" class="float-left" src="{{$appearance->logo}}" />
                            </div>
                            <input type="file" id="logo" accept="image/*" name="logo" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Background Image 1920x800')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <div class="w-100 float-left pb-2">
                                <img id="background-image-view" width="274" height="114" class="float-left" src="{{$appearance->background_image}}"/>
                            </div>
                            <input type="file" id="background_image" accept="image/*" name="background_image" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                           {{translate('Login Background 1920x1080')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <div class="w-100 float-left pb-2">
                                <img id="login-background-image-view" width="274" height="114" class="float-left" src="{{$appearance->login_background_image}}"/>
                            </div>
                            <input type="file" id="login_background_image" accept="image/*" name="login_background_image" />
                            <span class="help-block"></span>
                        </div>
                    </div>


                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                <i class="far fa-address-book"></i> {{translate('Contact Info')}}
                            </h4>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Email')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="email" id="contact_email" name="contact_email" value="{{$appearance->contact_email}}" class="form-control input-full" required data-validation-required-message="Email is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Phone')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="contact_phone" name="contact_phone" value="{{$appearance->contact_phone}}" class="form-control input-full" required data-validation-required-message="Phone No is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Website')}}
                            <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="contact_web" name="contact_web" value="{{$appearance->contact_web}}" class="form-control input-full" required data-validation-required-message="Website is required" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Address')}} <span class="required-label">*</span>
                        </label>
                        <div class="col-md-9 controls">
                            <textarea rows="4" id="address" required data-validation-required-message="Address is required" maxlength="500" name="address" class="form-control input-full">{{$appearance->address}}</textarea>
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                <i class="fas fa-link"></i> {{translate('Social Media Link')}}
                            </h4>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Facebook Link')}}
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="facebook_link" name="facebook_link" value="{{$appearance->facebook_link}}" class="form-control input-full" />
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Youtube Link')}}
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="youtube_link" name="youtube_link" class="form-control input-full" value="{{$appearance->youtube_link}}" />
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Twitter Link')}}
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="twitter_link" name="twitter_link" class="form-control input-full" value="{{$appearance->twitter_link}}" />
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Instagram Link')}}
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="instagram_link" name="instagram_link" class="form-control input-full" value="{{$appearance->instagram_link}}"/>
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                <i class="fab fa-font-awesome"></i> {{translate('SEO Settings')}}
                            </h4>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Meta Title')}}
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="meta_title" name="meta_title" class="form-control input-full" value="{{$appearance->meta_title}}" />
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Meta Description')}}
                        </label>
                        <div class="col-md-9 controls">
                            <textarea rows="10" id="meta_description" name="meta_description" class="form-control input-full">{{$appearance->meta_description}}</textarea>
                            <span class="help-block"></span>
                        </div>
                    </div>

                    <div class="form-group control-group form-inline ">
                        <label class="col-md-3">
                            {{translate('Meta keywords')}}
                        </label>
                        <div class="col-md-9 controls">
                            <input type="text" id="meta_keywords" name="meta_keywords" placeholder="Top Service, Best Teeth Cleaning" class="form-control input-full" value="{{$appearance->meta_keywords}}" />
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






@endsection