@extends('site.layouts.site')
@section('content')

<!--start banner section -->
<section class="banner-area position-relative" style="background:url({{$appearance->background_image}}) no-repeat;">
	<div class="overlay overlay-bg"></div>
	<div class="container">
		<div class="row">
			<div class="col-md-12">
				<div class="position-relative text-center">
					<h1 class="text-capitalize mb-3 text-white">{{translate('Photo Gallery')}}</h1>
					<a class="text-white" href="{{route('site.home')}}">{{translate('Home')}} </a>
					<i class="icofont-long-arrow-right text-white"></i>
					<a class="text-white" href="{{route('site.photo.gallery')}}">{{translate('Photo Gallery')}}</a>
				</div>
			</div>
		</div>
	</div>
</section>
<!-- end banner section -->

<!-- Start photo gallery area -->
<section class="section-gap">
	<div class="container">
		<h3>{{translate('Our Photo Gallery')}}</h3>
		<div class="row photo-gallery">
			@foreach ($photoGallery as $value)
			<div class="col-md-4">
				<a href="{{$value->image_url}}" class="img-gal">
					<div class="single-photo-gallery" style="background: url({{$value->image_url}});"></div>
				</a>
			</div>
			@endforeach
		</div>
	</div>
</section>
<!-- End photo gallery area -->


@endsection