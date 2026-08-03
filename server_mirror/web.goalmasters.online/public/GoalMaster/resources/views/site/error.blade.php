@extends('site.layouts.site')
@section('content')
@push("css")
<link href="{{ dsAsset('site/css/custom/error.css') }}" rel="stylesheet" />
@endpush


<section class="section-gap">
    <div class="container">
        <div class="row d-flex justify-content-center">
            <div class="col-lg-8">
                <div class="text-center">
                    <i class="fa fa-check-circle fa-5x color-danger" aria-hidden="true"></i>
                    <h1 class="mb-5">{{$data['message']}}</h1>
                    <p><a href="{{route($data['redirect_link'])}}">{{$data['redirect_text']}}</a></p>
                </div>
            </div>
        </div>
        
    </div>
</section>
@endsection