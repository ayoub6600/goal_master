@extends('site.layouts.site')
@section('content')

<!--start banner section -->
<section class="banner-area position-relative" style="background:url({{dsAsset($appearance->background_image)}}) no-repeat;">
	<div class="overlay overlay-bg"></div>
	<div class="container">
		<div class="row">
			<div class="col-md-12">
				<div class="position-relative text-center">
					<h1 class="text-capitalize mb-3 text-white">{{translate('Service Details')}}</h1>
					<a class="text-white" href="{{route('site.home')}}">{{translate('Home')}} </a>
					<i class="icofont-long-arrow-right text-white"></i>
					<a class="text-white" href="{{route('site.menu.services')}}"> {{translate('Service Details')}}</a>
				</div>
			</div>
		</div>
	</div>
</section>
<!-- end banner section -->

<!-- Start service details -->
<section class="section-gap section-service-details">
	<div class="container">
		<div class="row d-flex justify-content-center">
			<div class="col-lg-9">
				<div class="text-center pb-3">
					<h2 class="mb-10">{{translate('About')}} {{$serviceDetails->title}}</h2>
				</div>
			</div>
		</div>

		<div class="row service-details">
			<div class="col-lg-5">
				<div class="thum">
					<img src="{{dsAsset($serviceDetails->image)}}" alt="">
				</div>
			</div>
			<div class="col-lg-7">
				<div class="details">
					<p>{{$serviceDetails->remarks}}</p>
					<ul class="service-details-info">
						<li class="d-flex justify-content-between align-items-center">
							<span>{{translate('Total Service Time')}}</span>
							<span>{{$serviceDetails->time_slot_in_time}} minute</span>
						</li>
						<li class="d-flex justify-content-between align-items-center">
							<span>{{translate('Service Limit')}} {{$serviceDetails->appoinntment_limit_type}}</span>
							<span>{{$serviceDetails->appoinntment_limit}}</span>
						</li>
						<li class="d-flex justify-content-between align-items-center">
							<span>{{translate('Price per service')}} </span>
							<span>{{$serviceDetails->price}}</span>
						</li>
						<li class="d-flex justify-content-between align-items-center">
							<span>{{$serviceDetails->visibility}}</span>
							<a href="{{route('site.appoinment.booking')}}" class="btn btn-booking">{{translate('Book Now')}}</a>
						</li>
					</ul>

				</div>

			</div>


			<div class="col">
			@foreach ($serviceDetails->service_rating as $value)
			<hr>
				<div class="row">
					<div class="w100 pb-2">
						<div class="star mt-2">
							@for($i=1;$i<=5;$i++) @if ($value->rating>=$i)
								<span class="fa fa-star checked"></span>
								@else
								<span class="fa fa-star"></span>
								@endif
								@endfor
						</div>
					</div>
					<div class="w100 pb-2">
						by: {{$value->full_name}}
					</div>
					<div class="w100 pb-2">
						{{$value->feedback}}
					</div>
					
				</div>

				
			@endforeach	
			</div>
		</div>

	</div>
</section>
<!-- End service details -->


<!-- Start popular service -->
<section class="top-area section-gap">
	<div class="container">
		<div class="row d-flex justify-content-center">
			<div class="col-lg-9">
				<div class="text-center pb-3">
					<h3 class="mb-10">{{translate('Available Our Popular Services')}}</h3>
				</div>
			</div>
		</div>

		<div class="row">
			<div class="new-team owl-carousel owl-theme">
				@foreach ($topService as $value)
				<div class="single-item service-details-top-services">
					<div class="thum">
						<img class="img-fluid" src="{{dsAsset($value->image)}}" alt="Employee Image">
					</div>

					<div class="details">
						<div class="w100">
							<div class="star mt-2">
								@for($i=1;$i<=5;$i++) @if ($value->avgRating>=$i)
									<span class="fa fa-star checked"></span>
									@else
									<span class="fa fa-star"></span>
									@endif
									@endfor
									({{$value->countRating}})
							</div>
						</div>
						<h4 class="title">{{$value->title}}</h4>
						<p>
							{{$value->remarks}}
						</p>
						<div class="w-100 booking-div mt-2">
							<a href="{{route('site.appoinment.booking')}}" class="btn btn-booking-white">{{translate('Book Now')}}</a>
						</div>
					</div>
				</div>
				@endforeach

			</div>
		</div>

	</div>
</section>
<!-- End popular service -->
@endsection