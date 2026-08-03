@extends('site.layouts.site')
@section('content')
<!-- Start Slide-->

<section class="top-section">
	<div class="overlay overlay-bg"></div>
	<div class="top-banner" style="background:url({{$appearance->background_image}}) no-repeat;"></div>
	<div class="container top-banner-content">
		<div class="row">
			<div class="col-lg-5 col-md-5 col-xs-12 banner-right-content">
				<div class="margin-top-110 float-right-banner">
					<a href="{{route('site.appoinment.booking')}}" class="btn btn-booking btn-lg btn-full-round">{{translate('Book An Appointment')}} <i class="far fa-clock"></i></a>
				</div>
			</div>
			<div class="col-lg-7 col-md-7 col-xs-12 about-service">
				<div class="w100">
					<h1 class="mb-3"> {{$appearance->motto}}</h1>
					<p class="pr-5">
						{{$appearance->about_service}}
					</p>
				</div>
			</div>
		</div>
	</div>
</section>
<!--End Slide-->


<!-- Top Service Area -->
<section class="top-area section-gap">
	<div class="container">
		<div class="row website-service-summary">
			<div class="col-lg-3">
				<div class="single-item-service-summary mb-3">
					<div class="d-flex justify-content-center">
						<div class="float-start pt-3">
							<div class="icon-background icon-total-service">
								<img src="{{dsAsset('site/img/total-service.svg')}}" />
							</div>
						</div>
						<div class="float-start single-item-service-summary-content">
							<h2 class="text-total-service-count text-count mt-3">10</h2>
							<h4 class="text-service-title">{{translate('Total Services')}}</h4>
						</div>

					</div>
				</div>
			</div>

			<div class="col-lg-3">
				<div class="single-item-service-summary mb-3">
					<div class="d-flex justify-content-center">
						<div class="float-start pt-3">
							<div class="icon-background ico-background-exp-staff">
								<img src="{{dsAsset('site/img/expertise-staff.svg')}}" />
							</div>
						</div>
						<div class="float-start single-item-service-summary-content">
							<h2 class="text-count text-exp-staff-count mt-3">22</h2>
							<h4 class="text-service-title">{{translate('Expertise Staffs')}}</h4>
						</div>

					</div>
				</div>
			</div>

			<div class="col-lg-3">
				<div class="single-item-service-summary mb-3">
					<div class="d-flex justify-content-center">
						<div class="float-start pt-3">
							<div class="icon-background ico-background-satisfied-client">
								<img src="{{dsAsset('site/img/satisfied-client.svg')}}" />
							</div>
						</div>
						<div class="float-start single-item-service-summary-content">
							<h2 class="text-count text-satisfied-client-count mt-3">706</h2>
							<h4 class="text-service-title">{{translate('Satisfied Clients')}}</h4>
						</div>

					</div>
				</div>
			</div>

			<div class="col-lg-3">
				<div class="single-item-service-summary mb-3">
					<div class="d-flex justify-content-center">
						<div class="float-start pt-3">
							<div class="icon-background ico-background-done-service">
								<img src="{{dsAsset('site/img/done-service.svg')}}" />
							</div>
						</div>
						<div class="float-start single-item-service-summary-content">
							<h2 class="text-count text-done-service-count mt-3">519</h2>
							<h4 class="text-service-title">{{translate('Done Services')}}</h4>
						</div>

					</div>
				</div>
			</div>

	</div>
</section>
<!-- End top service Area -->

<!-- Start New Team Area -->
<section class="top-area section-gap">
	<div class="container">
		<div class="row d-flex justify-content-center">
			<div class="col-lg-9">
				<div class="text-center pb-3">
					<h2 class="mb-10">{{translate('Our new available playgrounds')}}</h2>
					<p>{{translate('We provide you with a service designed to meet your needs, ensuring you receive the utmost satisfaction and achieve your desired outcomes.')}}</p>
				</div>
			</div>
		</div>

		<div class="row">
			<div class="new-team owl-carousel owl-theme">
				@foreach ($newJoiningEmployee as $value)
				<div class="single-item">
					<div class="thum">
						<img class="img-fluid" src="{{$value->image_url}}" alt="Employee Image">
					</div>
					<div class="details">
						<h4 class="title">{{$value->full_name}}</h4>
						<p>
							{{$value->specialist}}
						</p>
						<a href="{{route('site.appoinment.booking')}}" class="btn btn-booking-white">{{translate('Book Now')}}</a>
					</div>
				</div>
				@endforeach

			</div>
		</div>
	</div>
</section>
<!-- End New Team Area -->

<!-- Start Client Testimonial Area -->
<section class="top-area section-gap">
	<div class="container">
		<div class="row d-flex justify-content-center">
			<div class="col-lg-9">
				<div class="text-center pb-3">
					<h2 class="mb-10">{{translate('Valuable Clients Testimonials')}}</h2>
					<p>{{translate('We got testimonials from our valued clients both online and offline and they are very much happy.')}}</p>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="top-client-testimonial owl-carousel owl-theme">
				@foreach ($clientTestimonial as $value)
				<div class="client-single-testimonial d-flex flex-row">
					<div class="thum">
						<img class="img-fluid" src="{{$value->image}}" alt="">
					</div>
					<div class="desctiotion">
						<p>
							{{$value->description}}
						</p>
						<h4>{{$value->name}}</h4>
						<div class="star">
							@for($i=1;$i<=5;$i++) @if ($i<=$value->rating)
								<span class="fa fa-star checked"></span>
								@else
								<span class="fa fa-star"></span>
								@endif
								@endfor
						</div>
					</div>
				</div>
				@endforeach

			</div>
		</div>
	</div>
</section>
<!-- End Client testimonial-->

@endsection