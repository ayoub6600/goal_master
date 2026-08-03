<?php
$shipping_details = "<br>";
if ($order->shipping_details) {
	$shipping_details .= ($order->shipping_details->full_name ?? '') . '<br>';
	// $shipping_details .= ($order->shipping_details->email ?? '') . '<br>';
	$shipping_details .= ($order->shipping_details->phone ?? '') . '<br>';
	$shipping_details .= ($order->shipping_details->address ?? '') . '<br>';
}
?>
@component('mail::message')
<table cellspacing="0" cellpadding="5">
	<tbody>
		<tr valign="top">
			<td>Order No: {{$order->code}}</td>
			<td>Order Date: {{$order->created_at}}</td>
		</tr>
		<tr valign="top">
			<td>Shipping address: {!!$shipping_details!!}</td>
			<td>Order Status: Processing<br/>Payment Status: {{ucfirst($order->payment_status)}}</td>
		</tr>
	</tbody>
</table>
<table style="width:100%" border="1" cellspacing="0" cellpadding="5">
	<thead>
		<tr>
			<th>#SL</th>
			<th>Item</th>
			<th>Quantity</th>
			<th>Unit Price</th>
			<th>Total Price</th>
		</tr>
	</thead>
	<tbody>@foreach ($order->details as $key => $details)
		<tr>
			<td>{{$key + 1}}</td>
			<td>{{$details->product->name}}</td>
			<td>{{$details->product_quantity}}</td>
			<td>{{$details->product_price}}</td>
			<td>{{$details->total_price}}</td>
		</tr>
		@endforeach
	</tbody>
</table>
@endcomponent