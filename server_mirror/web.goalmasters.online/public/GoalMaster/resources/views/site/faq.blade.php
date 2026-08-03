@extends('site.layouts.site')
@section('content')

<!--start banner section -->
<section class="banner-area position-relative" style="background:url({{$appearance->background_image}}) no-repeat;">
	<div class="overlay overlay-bg"></div>
	<div class="container">
		<div class="row">
			<div class="col-md-12">
				<div class="position-relative text-center">
					<h1 class="text-capitalize mb-3 text-white">{{translate('Frequently Asked Questions')}}</h1>
					<a class="text-white" href="{{route('site.home')}}">{{translate('Home')}} </a>
					<i class="icofont-long-arrow-right text-white"></i>
					<a class="text-white" href="{{route('site.faq')}}">{{translate('FAQ')}}</a>
				</div>
			</div>
		</div>
	</div>
</section>
<!-- end banner section -->

<!-- Start faq area -->
<section class="section-gap">
	<div class="container">
		<div class="accordion" id="accordionExample">
			<h3 class="pb-2">{{translate('Frequently Asked Questions')}}</h3>
			@foreach ($faq as $key=>$value)
			<div class="accordion-item single-faq">
				<h2 class="accordion-header" id="faq-item-{{$key}}">
					<button class="accordion-button{{$key==0?'':'  collapsed'}}" type="button" data-bs-toggle="collapse" data-bs-target="#collapse-{{$key}}" aria-expanded="{{$key==0?'true':'false'}}" aria-controls="collapse-{{$key}}">
						{{$key+1}}. {{$value->question}}
					</button>
				</h2>
				<div id="collapse-{{$key}}" class="accordion-collapse collapse{{$key==0?' show':''}}" aria-labelledby="faq-item-{{$key}}" data-bs-parent="#accordionExample">
					<div class="accordion-body">
						<div class="row">
							<div class="col-md-12 align-content-start">
								<p>{{$value->answer}}</p>
							</div>
						</div>
					</div>
				</div>
			</div>
			@endforeach
		</div>

	</div>
</section>
<!-- End faq area -->



@endsection