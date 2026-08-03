@extends('site.layouts.site-dashboard')
@section('content-site-dashboard')
@push("css")
<link href="{{ dsAsset('site/css/custom/client/client-dashboard.css') }}" rel="stylesheet" />
@endpush

<style>
  .ball {
      width: 50px;
      height: 50px;
      border-radius: 50%;
      background: url('{{ asset("img/ball.png") }}');
      background-size: cover;
      background-position: center;
      box-shadow: 
          inset -5px -5px 10px rgba(0, 0, 0, 0.2), 
          5px 5px 10px rgba(0, 0, 0, 0.3); 
      position: relative;
  }

  .ball-text {
      position: absolute;
      top: -20px; 
      left: 50%;
      transform: translateX(-50%);
      color: rgb(0, 0, 0);
      font-size: 18px;
      white-space: nowrap;
      font-weight: bold;
  }

  .bouncy-castle {
      height: 100%;
      left: 50%;
      position: absolute;
  }

  .bouncy-castle .ball-shadow {
      -webkit-animation-direction: alternate;
      -webkit-animation-duration: 1s;
      -webkit-animation-name: grow;
      -webkit-animation-iteration-count: infinite;
      animation-direction: alternate;
      animation-duration: 1s;
      animation-name: grow;
      animation-iteration-count: infinite;
      bottom: 0;
      position: absolute;
      margin-left: -100px;
  }

  .bouncy-castle .ball {
      -webkit-animation-direction: alternate;
      -webkit-animation-duration: 1s;
      -webkit-animation-name: bounce;
      -webkit-animation-iteration-count: infinite;
      animation-direction: alternate;
      animation-duration: 1s;
      animation-name: bounce;
      animation-iteration-count: infinite;
      margin-left: -100px;
      position: absolute;
  }

  @-webkit-keyframes grow {
      from {
          bottom: 0;
          margin-left: -100px;
          height: 50px;
          opacity: 1;
          width: 200px;
      }

      to {
          bottom: -15px;
          margin-left: -150px;
          height: 80px;
          opacity: 0.4;
          width: 300px;
      }
  }

  @keyframes grow {
      from {
          bottom: 0;
          margin-left: -100px;
          height: 50px;
          width: 200px;
      }

      to {
          bottom: 20px;
          margin-left: 0;
          height: 10px;
          width: 15px;
      }
  }

  @-webkit-keyframes bounce {
      from {
          bottom: 50px;
      }

      to {
          bottom: 100%;
      }
  }

  @keyframes bounce {
      from {
          bottom: 90%;
      }

      to {
          bottom: 110%;
      }
  }
</style>
<div class="row">
	<div class="col-md-4">
		<div class="card card-box-shadow card-service-status card-done mb-2">
			<div class="p-3  py-4">
				<span class="shape"></span>
				<div class="card-text-color">{{translate('Complete Booking')}}</div>
				<h3 class="mt-2 fw500"><i class="fa fa-check-circle color-done"></i> {{$bookingStatus['done']}}</h3>
			</div>
		</div>
	</div>

	<div class="col-md-4">
		<div class="card card-box-shadow card-service-status card-cancel mb-2">
			<div class="p-3  py-4">
				<span class="shape"></span>
				<div class="card-text-color">{{translate('Cancel Booking')}}</div>
				<h3 class="mt-2 fw500"><i class="fa fa-ban color-cancel"></i> {{$bookingStatus['cancel']}}</h3>
			</div>
		</div>
	</div>

	<div class="col-md-4">
		<div class="card card-box-shadow card-service-status card-pending mb-2">
			<div class="p-3  py-4">
				<span class="shape"></span>
				<div class="card-text-color">{{translate('Pending & Other')}}</div>
				<h3 class="mt-2 fw500"><i class="fas fa-clock color-pending"></i> {{$bookingStatus['others']}}</h3>
			</div>
		</div>
	</div>
	
</div>

<div class="row">
  <div class="col-md-4">
      <div class="card card-box-shadow card-service-status card-done mb-2">
          <div class="p-3  py-4">
              <span class="shape"></span>
              <div class="card-text-color">{{translate('Complete Booking')}}</div>
              <h3 class="mt-2 fw500"><i class="fa fa-check-circle color-done"></i> {{$bookingStatus['done']}}</h3>
          </div>
      </div>
  </div>

  <div class="col-md-4">
      <div class="card card-box-shadow card-service-status card-cancel mb-2">
          <div class="p-3  py-4">
              <span class="shape"></span>
              <div class="card-text-color">{{translate('Cancel Booking')}}</div>
              <h3 class="mt-2 fw500"><i class="fa fa-ban color-cancel"></i> {{$bookingStatus['cancel']}}</h3>
          </div>
      </div>
  </div>

  <div class="col-md-4">
      <div class="card card-box-shadow card-service-status card-pending mb-2">
          <div class="p-3  py-4">
              <span class="shape"></span>
              <div class="card-text-color">{{translate('Pending & Other')}}</div>
              <h3 class="mt-2 fw500"><i class="fas fa-clock color-pending"></i> {{$bookingStatus['others']}}</h3>
          </div>
      </div>
  </div>
</div>

<div class="row">
  <div class="col-md-12 mt-2">
      <div class="card card-box-shadow p-4 mh-425">
          <div class="row pl-4 pr-4 pb-2 pt-1">
              <div class="col-md-6 fs-18">
                  <h5>{{translate('Last 10 booking info')}}</h5>
              </div>

              <div class="col-md-6">
                  <a class="float-end btn btn-success btn-sm" href="{{route('site.appoinment.booking')}}">
                      <i class="fas fa-clock"></i>
                      <div class="bouncy-castle">
                          <div class="ball-shadow"></div>
                          <div class="ball">
                              <div class="ball-text">{{translate('New Booking')}}</div>
                          </div>
                      </div>
                  </a>
              </div>
          </div>

          <div class="col-md-12">
              <table class="table table-responsive w100" id="tableElement"></table>
          </div>
      </div>
  </div>
</div>
@push("scripts")
<script src="{{ dsAsset('site/js/custom/client/client-dashboard.js') }}"></script>
@endpush


@endsection