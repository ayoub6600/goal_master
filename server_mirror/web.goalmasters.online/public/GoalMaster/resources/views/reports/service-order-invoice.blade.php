<?php

$shipping_details = "<br>";
$totalAmt = 0;
$paidAmt = 0;
$dueAmt = 0;

if ($order != null) {
	$shipping_details .= 'الاسم الكامل: ' . ($order->full_name ?? 'غير متوفر') . '<br>';
	$shipping_details .= 'رقم الهاتف: ' . ($order->phone_no ?? 'غير متوفر') . '<br>';
} else {
	echo ("لا توجد بيانات متاحة");
	dd();
}

?>

<div style="width:100%;float:right;text-align:center;font-size:20px;font-weight:600;">{{$company_info->name}}</div>
<div style="width:100%;float:right;text-align:center;">{{$company_info->address}}</div>
<table cellspacing="0" cellpadding="5" style="width:100%;direction:rtl;text-align:right;margin-top:20px;">
	<tbody>
		<tr valign="top">
			<td>{{translate('رقم الطلب')}}: {{$order->id}}</td>
			<td>{{translate('تاريخ الطلب')}}:<br> {{$order->booking_date}}</td>
		</tr>
		<tr valign="top">
			<td><b>{{translate('بيانات العميل')}}</b> : {!!$shipping_details!!}</td>
		</tr>
	</tbody>
</table>

<table border="1" cellspacing="0" cellpadding="15" style="width:100%; margin:20px 0;direction:rtl;text-align:right;">
	<thead>
		<tr>
			<th>{{translate('م')}}</th>
			<th>{{translate('رقم الحجز')}}</th>
			<th>{{translate('الخدمة')}}</th>
			<th>{{translate('التاريخ والوقت')}}</th>
			<th>{{translate('السعر')}}</th>
			<th>{{translate('المبلغ المدفوع')}}</th>
			<th>{{translate('المبلغ المستحق')}}</th>
		</tr>
	</thead>
	<tbody>
		@foreach ($order->order_details as $key => $details)
		<?php
		$totalAmt += $details->service_amount;
		$paidAmt += $details->paid_amount;
		$dueAmt += $details->due;
		?>
		<tr>
			<td>{{$key + 1}}</td>
			<td>{{$details->id}}</td>
			<td>{{$details->service}}</td>
			@if($details->date)
                <td>
                    {{$details->date}} <br>
                    {{ 'من ' . \Carbon\Carbon::parse($details->start_time)->format('h:i A') }} <br>
                    {{ 'إلى ' . \Carbon\Carbon::parse($details->end_time)->format('h:i A') }}
                </td>
            @endif

			<td>{{$details->service_amount}}</td>
			<td>{{$details->paid_amount}}</td>
			<td>{{$details->due}}</td>
		</tr>
		@endforeach
	</tbody>
</table>

<div style="width:100%;float:right;">
	<div style="float:right;width:100%;text-align:right;padding-top:10px;">{{translate('إجمالي المبلغ')}}: {{round($totalAmt,2)}}</div>
	<div style="float:right;width:100%;text-align:right;padding-top:10px;">{{translate('الخصم')}}: {{round($order->coupon_discount,2)}}</div>
	<div style="float:right;width:100%;text-align:right;padding-top:10px;">{{translate('المبلغ المستحق بعد الخصم')}}: {{round($totalAmt - $order->coupon_discount,2)}}</div>
	<div style="float:right;width:100%;text-align:right;padding-top:10px;">{{translate('المبلغ المدفوع')}}: {{round($paidAmt,2)}}</div>
	<div style="float:right;width:100%;text-align:right;padding-top:10px;">{{translate('باقي')}}: {{round(($totalAmt - $order->coupon_discount) - $paidAmt,2)}}</div>
</div>