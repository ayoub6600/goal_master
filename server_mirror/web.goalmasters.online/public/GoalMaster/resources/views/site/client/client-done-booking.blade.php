@extends('site.layouts.site-dashboard')
@section('content-site-dashboard')
@push("scripts")
<script src="{{ dsAsset('site/js/custom/client/client-done-booking.js') }}"></script>
@endpush
@push("css")
<link href="{{ dsAsset('site/css/custom/client/client-done-booking.css') }}" rel="stylesheet" />
@endpush


<div class="row">
	<div class="col-md-12">
		<div class="card card-box-shadow p-4 card-done-booking">
			<div class="w-100 pb-3">
				<h5>{{translate('All done booking info')}}</h5>
			</div>
			<div class="col-md-12">
				<table class="table table-responsive w100" id="tableElement"></table>
			</div>
		</div>

	</div>
</div>

@endsection