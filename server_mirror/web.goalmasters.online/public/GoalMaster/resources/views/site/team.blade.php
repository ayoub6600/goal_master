	@extends('site.layouts.site')
	@section('content')
	<!--start banner section -->
	<section class="banner-area position-relative" style="background:url({{$appearance->background_image}}) no-repeat;">
		<div class="overlay overlay-bg"></div>
		<div class="container">
			<div class="row">
				<div class="col-md-12">
					<div class="position-relative text-center">
						<h1 class="text-capitalize mb-3 text-white">{{translate('Our Teams')}}</h1>
						<a class="text-white" href="{{route('site.home')}}">{{translate('Home')}} </a>
						<i class="icofont-long-arrow-right text-white"></i>
						<a class="text-white" href="{{route('site.menu.team')}}"> {{translate('Our Team')}}</a>
					</div>
				</div>
			</div>
		</div>
	</section>
	<!-- end banner section -->

	<!-- Start Team Area -->
	<section class="top-area section-gap">
		<div class="container">
			<div class="row d-flex justify-content-center">
				<div class="col-lg-9">
					<div class="text-center pb-3">
						<h2 class="mb-10">{{translate('Our Skilled Team Members')}}</h2>
						<p>{{translate('We always choose best team for your better services and better quality.')}}</p>
					</div>
				</div>
			</div>
			<div class="row">
				@foreach ($teams as $value)
				<div class="col-lg-3">
					<div class="single-our-team">
						<div class="thum">
							<img src="{{$value->image_url}}" alt="">
						</div>
						<div class="details">
							<h4 class="d-flex justify-content-between">
								<span>{{$value->full_name}}</span>
							</h4>
							<p>
								{{$value->specialist}}
							</p>
							<a href="{{route('site.single.team.details')}}/{{$value->id}}" class="">{{translate('Learn More')}} <i class="icofont-simple-right ml-2"></i></a>

						</div>
					</div>
				</div>
				@endforeach
			</div>
		</div>
	</section>
	<!-- End Team Area -->
	@endsection