@extends('site.layouts.site-dashboard')
@section('content-site-dashboard')
@push("scripts")
<script src="{{ dsAsset('site/js/custom/client/client-order.js') }}"></script>
@endpush

@push("css")
<link href="{{ dsAsset('site/css/custom/client/client-order.css') }}" rel="stylesheet" />
@endpush


<div class="row">
	<div class="col-md-12 mt-2">
		<div class="card card-box-shadow p-4 mh-425">
			<div class="row pl-4 pr-4 pb-2 pt-1">
				<div class="col-md-6 fs-18">
					<h5>{{translate('Your Orders')}}</h5>
				</div>

				<div class="col-md-12">
					<table class="table table-responsive w100" id="tableElement"></table>
				</div>
			</div>

		</div>
	</div>

	@endsection