@extends('layouts.app')
@section('content')
@push("adminScripts")
<script src="{{ dsAsset('js/lib/jq-treeview/jquery.cookie.js') }}"></script>
<script src="{{ dsAsset('js/lib/jq-treeview/jquery.treeview.js') }}"></script>
<script src="{{ dsAsset('js/custom/user_management/role-permission.js') }}"></script>
@endpush
@push("adminCss")
<link href="{{ dsAsset('js/lib/jq-treeview/jquery.treeview.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('css/custom/user_management/role-permission.css')}}" rel="stylesheet" />

@endpush


<!--User datatable-->
<div class="page-inner">
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            <i class="fas fa-user-shield"></i> {{translate('Role & Permission')}}
                        </h4>
                        <a href="{{ route('role') }}" class="btn btn-primary btn-sm btn-round ml-auto pull-left">
                            <i class="fa fa-plus"></i> {{translate('Add New Role')}}
                        </a>

                    </div>
                </div>
                <div class="card-body">
                    <div class="form-group form-inline">
                        <label class="col-md-2 col-form-label">
                            {{translate('Role Name')}}
                            <span class="required-label"> *</span>
                        </label>
                        <div class="col-md-4">
                            <select class="form-control input-full" id="cmbRole"></select>
                        </div>

                        <div class="col-md-6">
                            <button id="btnSaveRolePermission" class="btn btn-success btn-sm pull-right">
                                <i class="fas fa-save"></i> {{translate('Save Role Permission')}}
                            </button>

                        </div>

                    </div>
                    <div class="row">
                        <div class="offset-2 col-md-10">

                            <ul id="red" class="treeview-red" style="margin-bottom: 50px;">
                                <b class="fs-11rem menu-tree-color"> {{translate('Menu List')}}</b>
                                <li>
                                    <input type="checkbox" data-type="NO" class="chkPermission chkPermissionAll" data-roleprmiid="0" id="Chk_Parent" /> {{translate('Select All')}}
                                    <ul>
                                        @foreach ($resourceList->where('level', 1) as $resource)
                                        <li class="parentLi">
                                            <input type="checkbox" {{ $resource->status?"checked":"" }} class="chkPermission chkPermissionAll" data-resid="{{ $resource->id }}" />
                                            <input type="text" disabled="disabled" class="txtDisplayName" placeholder="{{ $resource->org_display_name }}" value="{{ $resource->display_name }}" />
                                            @foreach ($resource->role as $role)
                                            <input type="checkbox" {{$role->status?"checked":""}}" class="chkPermission1 chkPermissionAll" data-roleprmiid="{{$role->id}}" data-resid="{{$resource->id}}" />
                                            {{ $role->permission_name }}
                                            @endforeach
                                            <span title="{{translate('click for edit')}}" data-resid='{{ $resource->id }}' class="fas fa-edit editIcon" onclick="EditSpan(this);"></span>
                                            <span title="{{translate('click to save')}}" data-resid='{{ $resource->id }}' class="fas fa-check saveIcon" onclick="SaveSpan(this);"></span>

                                            <ul>
                                                @foreach ($resourceList->where('level',2)->where('sec_resource_id',$resource->id) as $resource1)
                                                    <!-- if statement for Hide  Role Info and Role Permission -->
                                                    @if (!($resource1->org_display_name =='Role Info' || $resource1->org_display_name =='Role Permission' || $resource1->org_display_name =='Department'))
                                                        <li>
                                                            <input type="checkbox" {{ $resource1->status?"checked":"" }} class="chkPermission chkPermissionAll" data-resid="{{ $resource1->id }}" />
                                                            <input type="text" disabled="disabled" class="txtDisplayName" placeholder="{{ $resource1->org_display_name }}" value="{{ $resource1->display_name }}" />
                                                            @foreach ($resource1->role as $role1)
                                                            <input type="checkbox" {{ $role1->status?"checked":"" }} class="chkPermission1 chkPermissionAll" data-roleprmiid="{{$role1->id}}" data-resid="{{$resource1->id}}" />
                                                            {{ $role1->permission_name }}
                                                            @endforeach
                                                            <span title="{{translate('click for edit')}}" data-resid='{{ $resource1->id }}' class="fas fa-edit editIcon" onclick="EditSpan(this);"></span>
                                                            <span title="{{translate('click to save')}}" data-resid='{{ $resource1->id }}' class="fas fa-check saveIcon" onclick="SaveSpan(this);"></span>
                                                            <ul>
                                                                @foreach ($resourceList->where('level',3)->where('sec_resource_id',$resource1->id) as $resource2)
                                                                <li>
                                                                    <input type="checkbox" {{ $resource2->status?"checked":"" }} class="chkPermission chkPermissionAll" data-resid="{{ $resource2->id }}" />
                                                                    <input type="text" disabled="disabled" class="txtDisplayName" placeholder="{{ $resource2->org_display_name }}" value="{{ $resource2->display_name }}" />
                                                                    @foreach ($resource2->role as $role2)
                                                                    <input type="checkbox" {{ $role->status?"checked":"" }} class="chkPermission1 chkPermissionAll" data-roleprmiid="{{$role2->id}}" data-resid="{{$resource2->id}}" />
                                                                    {{ $role2->permission_name }}
                                                                    @endforeach
                                                                    <span title="{{translate('click for edit')}}" data-resid='{{ $resource2->id }}' class="fas fa-edit editIcon" onclick="EditSpan(this);"></span>
                                                                    <span title="{{translate('click to save')}}" data-resid='{{ $resource2->id }}' class="fas fa-check saveIcon" onclick="SaveSpan(this);"></span>

                                                                </li>
                                                                @endforeach
                                                            </ul>

                                                        </li>
                                                    @endif
                                                @endforeach
                                            </ul>

                                        </li>
                                        @endforeach
                                    </ul>
                                </li>
                            </ul>

                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

@endsection