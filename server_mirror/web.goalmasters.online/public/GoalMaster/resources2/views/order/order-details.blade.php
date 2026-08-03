@extends('layouts.app')
@section('content')
<div class="page-inner">
	<div class="row">
		<div class="col-md-12 mt-2">
			<div class="card card-box-shadow p-4 mh-425">
				<div class="row pl-4 pr-4 pb-2 pt-1">
					<div class="col-md-6 fs-18">
						<h5>{{translate('Your Orders Details')}}</h5>
					</div>

					<div class="col-md-12">
						<div class="row mb-4">
							<div class="col-md-6">Order No: {{$order->code}}</div>
							<div class="col-md-6">Order Date: {{$order->created_at}}</div>
							<div class="col-md-6">Shipping address:
								<?php
								$shipping_details = "<br>";
								if ($order->shipping_details) {
									$shipping_details .= ($order->shipping_details->full_name ?? '') . '<br>';
									// $shipping_details .= ($order->shipping_details->email ?? '') . '<br>';
									$shipping_details .= ($order->shipping_details->phone ?? '') . '<br>';
									$shipping_details .= ($order->shipping_details->address ?? '') . '<br>';
								}
								echo $shipping_details;
								?>
							</div>
							<div class="col-md-6">
								Paymnet Status: {{$order->payment_status}}<br />
								Order Status: {{$order_status}}
								<div class="form-inline">
									<label class="col-form-label">Change Status</label>
									<select class="form-control" id="change-status">
										<option value="1" @if($order->status == 1) selected @endif>Processing</option>
										<option value="2" @if($order->status == 2) selected @endif>Shipped</option>
										<option value="3" @if($order->status == 3) selected @endif>Deliverd</option>
										<option value="4" @if($order->status == 4) selected @endif>Cancled</option>
									</select>
								</div>

							</div>
						</div>
						<div class="row">
							<div class="col-md-1">#SL</div>
							<div class="col-md-5">Item</div>
							<div class="col-md-2">Quantity</div>
							<div class="col-md-2">Unit Price</div>
							<div class="col-md-2">Total Price</div>
							<div class="col-12">
								<hr class="my-1">
							</div>
						</div>
						@foreach($order->details as $keyD => $details)
						<div class="row">
							<div class="col-md-1">{{$keyD+1}}</div>
							<div class="col-md-5">{{$details->product->name}}</div>
							<div class="col-md-2">{{$details->product_quantity}}</div>
							<div class="col-md-2">{{$details->product_price}}</div>
							<div class="col-md-2">{{$details->total_price}}</div>
						</div>
						@endforeach
					</div>
				</div>

			</div>
		</div>
	</div>
	@push("adminScripts")
	<script type="text/javascript">
		var orderId = {{\Route::current()-> parameters["order"]->id}};
	</script>
	<script src="{{ dsAsset('js/custom/order/order_details.js') }}"></script>
	<style type="text/css">
		#change-status {
			margin-left: 10px;
		}
	</style>
	@endpush


	@endsection