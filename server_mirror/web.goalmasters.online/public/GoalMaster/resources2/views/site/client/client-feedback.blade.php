@extends('site.layouts.site-dashboard')
@section('content-site-dashboard')

<div class="row">
	<div class="col-md-12 mt-2">
		<div class="card card-box-shadow p-4 mh-425">
			<div class="row pl-4 pr-4 pb-2 pt-1">
			<div class="col-md-6 fs-18">
				<h5>{{translate('Service Feedback')}}</h5>
			</div>
			
			<div class="col-md-6 offset-md-3">
				<p class="mb-5">					
					Booking Date: {{$feedback->booking->date}}<br>
				</p>
				@if($feedback->status == 0)
				<form class="form-horizontal" action="{{route('site.client.service.feedback.post',['schServiceFeedback' => $feedback->hash_code])}}" method="POST">
					@csrf
					<div class="form-group">
						<label class="col-md-12">{{translate('Rating')}}</label>
						<select class="form-control col-md-12" name="rating">
							<option>1</option>
							<option>2</option>
							<option>3</option>
							<option>4</option>
							<option>5</option>
						</select>
					</div>
					<div class="form-group mt-3">
						<label class="col-md-12">{{translate('Feedback')}}</label>
						<textarea class="col-md-12 form-control" rows="5" name="feedback"></textarea>
					</div>
					<div class="form-group mt-3">
						<button class="btn btn-success">{{translate('Submit')}}</button>
					</div>
				</form>
				@else
				<p>Rating : {{$feedback->rating}}</p>
				<p>Feedback : {{nl2br($feedback->feedback)}}</p>
				<p>Submited On : {{$feedback->updated_at}}</p>
				@endif
			</div>
		</div>

	</div>
</div>
@endsection