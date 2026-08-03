@extends('layouts.app')
@section('content')
<div class="page-inner">

    <div class="row">
        <div class="col-md-12">
            <div class="main-card card">
                <form id="inputForm" novalidate="novalidate">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <h4 class="card-title">
                                {{translate('Translate')}} English => <b>{{$translateLang}}</b>
                            </h4>
                        </div>
                    </div>
                    <div class="card-body pt-1">
                        <table id="tableElement" class="table table-bordered w100"></table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" id="btnSave" class="btn btn-success btn-shadow">{{translate('Save Change')}}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@push("adminScripts")
<script src="{{ dsAsset('js/custom/settings/translate.js') }}"></script>
@endpush
@endsection