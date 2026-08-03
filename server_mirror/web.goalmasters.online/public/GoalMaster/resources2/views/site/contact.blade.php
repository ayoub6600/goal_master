@extends('site.layouts.site')
@section('content')

<!--start banner section -->
<section class="banner-area position-relative" style="background:url({{$appearance->background_image}}) no-repeat;">
    <div class="overlay overlay-bg"></div>
    <div class="container">
        <div class="row">
            <div class="col-md-12">
                <div class="position-relative text-center">
                    <h1 class="text-capitalize mb-3 text-white">{{translate('Contact Us')}}</h1>
                    <a class="text-white" href="{{route('site.home')}}">{{translate('Home')}} </a>
                    <i class="icofont-long-arrow-right text-white"></i>
                    <a class="text-white" href="{{route('site.contact')}}"> {{translate('Contact Us')}}</a></p>
                </div>
            </div>
        </div>
    </div>
</section>
<!-- end banner section -->

<!-- Start about-info Area -->
<section class="top-area section-gap">
    <div class="container">
        <div class="row d-flex justify-content-center">
            <div class="col-lg-9">
                <div class="text-center pb-3">
                    <h2 class="mb-10">{{translate('Contact Us')}}</h2>
                    <p>{{translate('For any query contact us by email or phone')}}</p>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-5 col-md-5 col-sm-12 contact-address">
                <div class="single-contact d-flex flex-row">
                    <div class="icon">
                        <i class="fas fa-home"></i>
                    </div>
                    <div class="contact-details">
                        <p class="address">
						{{$appearance->address}}
                        </p>
                    </div>
                </div>
                <div class="single-contact d-flex flex-row">
                    <div class="icon">
                        <i class="fas fa-phone-alt"></i>
                    </div>
                    <div class="contact-details">
                        <h5>{{$appearance->contact_phone}}</h5>
                        <p>{{translate('Call us in Office time only')}}</p>
                    </div>
                </div>
                <div class="single-contact d-flex flex-row">
                    <div class="icon">
                        <i class="far fa-envelope-open"></i>
                    </div>
                    <div class="contact-details">
                        <h5>{{$appearance->contact_email}}</h5>
                        <p>{{translate('Send your query anytime!')}}</p>
                    </div>
                </div>
            </div>
            <div class="col-lg-7 col-md-7 col-sm-12 contact-us-email">
                <form  id="form-send-notification">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <input required name="name" id="name" type="text" class="form-control" placeholder="{{translate('Your Full Name')}}">
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <input required name="email" id="email" type="email" class="form-control" placeholder="{{translate('Your Email Address')}}">
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="mb-3">
                                <input required name="subject" id="subject" type="text" class="form-control" placeholder="{{translate('Your Query Topic/Subject')}}">
                            </div>
                        </div>                       
                    </div>
                    <div class="mb-4">
                        <textarea required name="message" id="message" class="form-control" rows="8" placeholder="{{translate('Your Message')}}"></textarea>
                    </div>
                    <div class="text-center">
                        <button class="btn btn-booking float-end pe-4 ps-4">{{translate('Send Mail')}}</button>
                    </div>
                </form>
            </div>
        </div>


        <div class="row align-items-center mt-4">
            <div class="col-lg-12 col-md-12 col-sm-12">
                <h3 class="ps-2">{{translate('Our Map Location')}}</h3>
				<input type="hidden" id="maplat" value="{{$gMapConfig['lat']}}"/>
			<input type="hidden" id="maplong" value="{{$gMapConfig['long']}}" />
                <div class="map-wrap" style="width: 100%; height: 445px;" id="map"></div>
            </div>
        </div>
    </div>
</section>
<!-- End about-info Area -->
@push("scripts")
<script src="https://maps.googleapis.com/maps/api/js?key={{$gMapConfig['map_key']}}"></script>
<script src="{{ dsAsset('site/js/custom/client-notification.js') }}"></script>
@endpush


@endsection