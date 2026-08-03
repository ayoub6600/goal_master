@extends('site.layouts.site')
@section('content')
<!--start banner section -->
<section class="banner-area position-relative" style="background:url({{$appearance->background_image}}) no-repeat;">
	<div class="overlay overlay-bg"></div>
	<div class="container">
		<div class="row">
			<div class="col-md-12">
				<div class="position-relative text-center">
					<h1 class="text-capitalize mb-3 text-white">{{translate('Terms & Conditions')}}</h1>
					<a class="text-white" href="{{route('site.home')}}">{{translate('Footer Link')}} </a>
					<i class="icofont-long-arrow-right text-white"></i>
					<a class="text-white" href="{{route('site.terms.and.condition')}}"> {{translate('Terms & Conditions')}}</a>
				</div>
			</div>
		</div>
	</div>
</section>
<!-- end banner section -->

<section class="section-gap top-terms-and-condition">
	<div class="container">
		<div class="row">
			<div class="terms-condition-area col-md-12 col-sm-12 col-lg-12">

				{!!$termsAndCondition['details']!!}

			</div>
		</div>
	</div>
</section>
@endsection