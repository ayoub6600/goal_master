	@extends('site.layouts.site')
	@section('content')
	<!-- Start Voucher Area -->
	<section class="top-area section-gap">
		<div class="container">
			<div class="row">
				<div class="col-12 col-md-9">
					<div class="card">
						<div class="card-body">
					    <h5 class="card-title">Cart Details</h5>
							<table class="table table-bordered table-responsive">
								<thead>
									<tr>
										<th>#{{translate('SL')}}</th>
										<th>{{translate('Item')}}</th>
										<th>{{translate('Quantity')}}</th>
										<th>{{translate('Unit Price')}}</th>
										<th>{{translate('Total Price')}}</th>
										<th>{{translate('OPT')}}</th>
									</tr>
								</thead>
								<tbody>
									@foreach ($carts as $key => $cart)
									<tr>
										<td>{{$key + 1}}</td>
										<td>{{$cart['name']}}</td>
										<td>{{$cart['quantity']}}</td>
										<td>{{$cart['price']}}</td>
										<td>{{$cart['total_price']}}</td>
										<td><i class="fa fa-trash cursor-pointer remove-from-cart text-danger" data-index="{{$key}}"></i></td>
									</tr>
									@endforeach	
								</tbody>
								@if($carts->count() < 1)
								<tfoot>
									<tr>
										<td colspan="6">{{translate('You have no item in your cart')}}</td>
									</tr>
								</tfoot>
								@endif
							</table>
						</div>
					</div>
				</div>
				<div class="col-12 col-md-3">
					<div class="card">
					  <div class="card-body">
					    <h5 class="card-title">Cart Summery</h5>
					    <table class="table table-sm table-borderless mt-4">
					    	<tbody>
					    		<tr class="bdr-bottom">
					    			<td>Total Item</td>
					    			<td>{{$carts->count()}}</td>
					    		</tr>
					    		<tr class="bdr-bottom">
					    			<td>Total Amount</td>
					    			<td>{{$carts->sum('total_price')}}</td>
					    		</tr>
					    	</tbody>
					    </table>
					    <a href="{{route('site.checkout.shipping')}}" class="btn btn-success">{{translate('Procced To Checkout')}}</a>
					  </div>
					</div>
				</div>
			</div>
		</div>
	</section>
	<!-- End Voucher Area -->
	@endsection