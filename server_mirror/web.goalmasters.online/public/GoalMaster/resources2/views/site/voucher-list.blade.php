	@extends('site.layouts.site')
	@section('content')

	<!-- Start Voucher Area -->
	<section class="top-area section-gap">
		<div class="container">
			<div class="row">
				@foreach ($vouchers as $value)
				<div class="col-lg-4">
					<div class="single-service single-service-voucher">
						<div class="thum">
							<img src="{{$value->thumbnail}}" alt="">
						</div>
						<div class="details">
							<h4>{{$value->name}}</h4>
							<p>{{$value->description}}</p>
							<ul class="single-service-info">
								<li class="d-flex justify-content-between align-items-center fs-18">
									<span>{{translate('Price')}} </span>
									<b>{{round($value->price,2)}}</b>
								</li>
								<li class="d-flex justify-content-between align-items-center">
									<button type="button" class="btn btn-booking-white add-to-cart" data-id="{{$value->id}}">{{translate('Add To Cart')}}</a>
								</li>
							</ul>
						</div>
					</div>
				</div>
				@endforeach
			</div>
			<div class="row d-flex justify-content-center">
				<div class="col-12 mt-4">
					{{$vouchers->links('pagination::bootstrap-4')}}
				</div>
			</div>
		</div>
	</section>
	<!-- End Voucher Area -->
	@endsection