@extends('layouts.app')
@section('content')
@push("adminCss")
<link href="{{ dsAsset('js/lib/codemirror/codemirror.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/tui.editor/toastui-editor.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/tui.editor/toastui-editor-viewer.css') }}" rel="stylesheet" />
@endpush

@push("adminScripts")
<script src="{{ dsAsset('js/lib/codemirror/codemirror.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.editor/toastui-editor-viewer.js') }}"></script>
<script src="{{ dsAsset('js/lib/tui.editor/toastui-editor.js') }}"></script>
<script src="{{ dsAsset('js/custom/website/terms-and-condition.js') }}"></script>
@endpush




<div class="page-inner">
    <form class="form-horizontal" id="inputForm" novalidate="novalidate">
    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <div class="card-header">
                    <div class="d-flex align-items-center">
                        <h4 class="card-title">
                            {{translate('Terms & Conditions')}}
                        </h4>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-12">
                            <div id="editor">{!!$termsCondition->details!!}</div>
                        </div>
                    </div>
                    <div class="form-group control-group form-inline">
                        <label class="switch">
                            @if ($termsCondition->status==1)
                            <input id=status name="status" checked type="checkbox" value="{{ json_decode($termsCondition->status)}}" class="rm-slider">
                            @else
                            <input id=status name="status" type="checkbox" value="{{$termsCondition->status}}" class="rm-slider">
                            @endif
                           
                            <span class="slider round"></span>
                        </label>
                        <label class="pt-1 ml-1"> {{translate('Active Terms & Conditions')}} </label>
                        <span class="help-block"></span>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-success">{{translate('Save Change')}}</button>
                </div>
            </div>
        </div>
    </div>
    </form>

</div>



@endsection