@extends('site.layouts.site-dashboard')
@section('content-site-dashboard')
@push("css")
<link href="{{ dsAsset('site/css/custom/client/client-pending-booking.css') }}" rel="stylesheet" />
@endpush


<div class="row">
	<div class="col-md-12">
		<div class="card card-box-shadow card-pending-booking p-4">
			<div class="w-100 pb-3">
			<h5>{{translate('All pending & other booking info')}}</h5>
			</div>
			<div class="col-md-12">
				<table class="table table-responsive w100" id="tableElement"></table>
			</div>
		</div>

	</div>
</div>
@push("scripts")
<script src="{{ dsAsset('site/js/custom/client/client-pending-booking.js') }}"></script>
@endpush


@endsection