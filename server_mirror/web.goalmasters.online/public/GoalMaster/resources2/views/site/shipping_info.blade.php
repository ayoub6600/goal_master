	@extends('site.layouts.site')
	@section('content')


	<!-- Start Voucher Area -->
	<section class="top-area section-gap">
		<div class="container">
			<div class="row">
				<div class="offset-md-3 col-md-6">
					<div class="card shipping-address-card">
						<div class="card-body">
					    	<h5 class="card-title">Shipping Details</h5>
							<form id="shipping-form" class="form-horizontal" method="post" autocomplete="off" action="{{route('site.checkout.shippingInfo')}}">
								@csrf
								<div class="form-group pb-3">
									<label class="form-label">Full Name</label>
									<input type="text" name="full_name" placeholder="Full name" class="form-control" value="{{session()->get('cart_shipping.name',$user->name)}}" required>
								</div>
								<div class="form-group pb-3">
									<label class="form-label">Email</label>
									<input type="email" name="email" placeholder="Email" class="form-control" value="{{session()->get('cart_shipping.email',$user->email)}}" required>
								</div>
								<div class="form-group pb-3">
									<label class="form-label">Phone</label>
									<input type="text" name="phone" placeholder="Phone" class="form-control" value="{{session()->get('cart_shipping.phone','')}}" required>
								</div>
								<div class="form-group pb-3">
									<label class="form-label">Address</label>
									
									<textarea rows="4" name="address" placeholder="Address" class="form-control" required>{{session()->get('cart_shipping.address','')}}</textarea>
								</div>
								<div class="form-group">
									<button class="btn btn-success">Procced to Payment</button>
								</div>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>
	</section>
	<!-- End Voucher Area -->
	@endsection