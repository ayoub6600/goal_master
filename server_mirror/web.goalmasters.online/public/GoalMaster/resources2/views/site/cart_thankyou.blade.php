	@extends('site.layouts.site')
	@section('content')
	<!--start banner section -->
	<section class="banner-area position-relative" style="background:url({{$appearance->background_image}}) no-repeat;">
		<div class="overlay overlay-bg"></div>
		<div class="container">
			<div class="row">
				<div class="col-md-12">
					<div class="position-relative text-center">
						<h1 class="text-capitalize mb-3 text-white">{{translate('Thank You')}}</h1>
						<a class="text-white" href="{{route('site.home')}}">{{translate('Home')}} </a>
						<i class="icofont-long-arrow-right text-white"></i>
						<a class="text-white" href="{{route('site.cart')}}"> {{translate('Cart')}}</a>
						<i class="icofont-long-arrow-right text-white"></i>
						<a class="text-white" href="{{route('site.order.thankyou',['cmnOrder' => $order->code])}}"> {{translate('Order Complete')}}</a>
					</div>
				</div>
			</div>
		</div>
	</section>
	<!-- end banner section -->

	<!-- Start Voucher Area -->
	<section class="top-area section-gap">
		<div class="container">
			<div class="row">
				<div class="col-12 col-md-12">
					<div class="card">
						<div class="card-body">
					    	<h5 class="card-title">Order Placed</h5>
							<p>Your order {{$order->code}} has been placed, our admin will communicate with you shortly.</p>
						</div>
					</div>
				</div>
			</div>
		</div>
	</section>
	<!-- End Voucher Area -->
	@endsection