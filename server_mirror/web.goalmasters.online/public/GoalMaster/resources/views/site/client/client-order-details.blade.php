@extends('site.layouts.site-dashboard')
@section('content-site-dashboard')
@push("css")
<link href="{{ dsAsset('site/css/custom/client/client-order-details.css') }}" rel="stylesheet" />
@endpush

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
						if($order->shipping_details){
							$shipping_details .= ($order->shipping_details->full_name??'').'<br>';
							$shipping_details .= ($order->shipping_details->email??'').'<br>';
							$shipping_details .= ($order->shipping_details->phone??'').'<br>';
							$shipping_details .= ($order->shipping_details->address??'').'<br>';
						}
						echo $shipping_details;
						?>
					</div>
					<div class="col-md-6">Order Status: {{$order_status}}</div>
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
@push("scripts")
<script src="{{ dsAsset('site/js/custom/client/client-order-details.js') }}"></script>
@endpush


@endsection