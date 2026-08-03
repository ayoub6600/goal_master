@extends('site.layouts.site')
@section('content')

<!--start banner section -->
<section class="banner-area position-relative" style="background:url({{dsAsset($appearance->background_image)}}) no-repeat;">
    <div class="overlay overlay-bg"></div>
    <div class="container">
        <div class="row">
            <div class="col-md-12">
                <div class="position-relative text-center">
                    <h1 class="text-capitalize mb-3 text-white">{{translate('Staff Information')}}</h1>
                    <a class="text-white" href="{{route('site.home')}}">{{translate('Home')}} </a>
                    <i class="icofont-long-arrow-right text-white"></i>
                    <a class="text-white" href="{{route('site.menu.team')}}"> {{translate('Staff Information')}}</a>
                </div>
            </div>
        </div>
    </div>
</section>
<!-- end banner section -->

<section class="section-gap section-team-details">
    <div class="container">
        <div class="row team-details">
            <div class="col-lg-4">
                <div class="thum">
                    <img src="{{dsAsset($teamDetails->image_url)}}" alt="Employee Image">
                </div>
            </div>
            <div class="col-lg-6">
                <div class="details">
                    <h2 class="mb-10">{{$teamDetails->full_name}}</h2>
                    <h4>{{translate('Available In Branch')}}</h4>
                    <p>{{$teamDetails->branch}}</p>

                    <h4>{{translate('Specialist')}}</h4>
                    <p>{{$teamDetails->specialist}}</p>

                </div>

            </div>
        </div>
    </div>
</section>

<!-- Start Service Area -->
<section class="top-area section-gap">
    <div class="container">
        <div class="row d-flex justify-content-center">
            <div class="col-lg-12">
                <div class="text-start pb-3">
                    <h3 class="mb-10"> {{$teamDetails->full_name}}{{translate(' Provides below services')}}</h3>
                </div>
            </div>
        </div>

        <div class="row staff-related-service">
            @foreach ($teamDetails->services as $value)
            <div class="col-lg-3 col-md-6">
                <div class="single-item">
                    <div class="thum">
                        <img class="img-fluid" src="{{dsAsset($value->image)}}" alt="">
                    </div>
                    <a href="{{route('site.appoinment.booking')}}">
                        <h4>{{$value->title}}</h4>
                    </a>
                    <p>
                        {{$value->remarks}}
                    </p>
                    <a href="{{route('site.service.single.details')}}/{{$value->id}}" class="read-more">{{translate('Learn More')}} <i class="icofont-simple-right ml-2"></i></a>
                </div>
            </div>
            @endforeach
        </div>
    </div>
    </div>
    </div>
</section>


@endsection