@extends('layouts.app')

@section('content')
<div class="panel-header bg-danger-gradient">
    <div class="page-inner py-5">
        <div class="d-flex align-items-left align-items-md-center flex-column flex-md-row">
            <div>
                <h2 class="text-white pb-2 fw-bold">{{translate('Error Page')}}</h2>
                <h5 class="text-white op-7 mb-2">{{$msg}}</h5>
            </div>
            <div class="ml-md-auto py-2 py-md-0">
                <a href="{{route('home')}}" class="btn btn-secondary btn-round">{{translate('Go To Home')}}</a>
            </div>
        </div>
    </div>
</div>

@endsection
