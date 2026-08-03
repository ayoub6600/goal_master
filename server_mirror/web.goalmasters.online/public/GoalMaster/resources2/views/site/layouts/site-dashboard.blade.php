@extends('site.layouts.site')
@section('content')
@push("css")
<!-- datatable css -->
<link href="{{ dsAsset('js/lib/DataTables/datatables.min.css') }}" rel="stylesheet" />

<link href="{{ dsAsset('site/css/custom/client/site-dashboard.css') }}" rel="stylesheet" />
@endpush


<script>
	// Automatically hide the alert after 3 seconds
	setTimeout(function() {
		let alertMasseg = document.getElementById('alertMasseg');
		if (alertMasseg) {
			alertMasseg.classList.remove('show');
			alertMasseg.classList.add('fade');
		}
	}, 3000); // 3000 milliseconds = 3 seconds
</script>


<style>
	.slide-down {
		animation: slideDown 0.5s ease-out;
		/* Animation duration and easing */
	}

	@keyframes slideDown {
		from {
			top: -100px;
			/* Start above the viewport */
			opacity: 0;
		}

		to {
			top: 20px;
			/* End at a position slightly below the top */
			opacity: 1;
		}
	}

	.btn-gradient-green {
    background: linear-gradient(135deg, #28a745, #218838);
    border: none;
    transition: all 0.3s ease-in-out;
}

.btn-gradient-green:hover {
    background: linear-gradient(135deg, #218838, #1e7e34);
    transform: scale(1.05);
}

.btn-gradient-green:active {
    transform: scale(0.95);
}

</style>


@if (session('error'))
<div class="alert alert-danger alert-dismissible fade show slide-down" id="alertMasseg">
	{{ session('error') }}
</div>
@endif

@if (session('success'))
<div class="alert alert-success  alert-dismissible fade show slide-down" id="alertMasseg">
	{{ session('success') }}
	@if(session('card_code'))
	<br>Card Code: {{ session('card_code') }}
	@endif
</div>
@endif




<div class="container mt-5">
	<div class="section-top-border">
		<div class="row mt-5">
			<div class="col-md-3">

				<div class="sidebar-menu">
					<div class="leftside-menu">
						<div class="card card-box-shadow py-4 mb-3">
							<span class="lm-shape"></span> <span class="lm-shape2"></span>
							<div class="card-header bg-transparent">
								<div class="div-profile-image justify-content-center d-flex">
									@if($userInfo['photo']==null || $userInfo['photo']=='')
									<img class="profile-image" src="{{ dsAsset('js/lib/assets/img/avater-man.png') }}" alt="" class="avatar-img rounded" />
									@else
									<img class="profile-image" src="{{ dsAsset($userInfo['photo']) }}" alt="" class="avatar-img rounded" />
									@endif
								</div>
								<h4 class="mb-0 mt-1 text-center fw400">{{$userInfo['name']}}</h4>
								<div class="text-center fs-13 user-balance mt-3">
									<span>{{translate('Balance')}} : {{auth()->user()->balance()}}</span>
								</div>
								<br>
								<!-- Button to trigger modal -->
								<div class="justify-content-space-between align-items-center d-flex flex-column">
									<button type="button" class="btn btn-warning text-center fs-15 " data-toggle="modal" data-target="#chargeCardModal" onclick="showAddBalanceModal()">
										{{translate('Charge Card')}}
									</button>
									<a class="btn btn-gradient-green btn-lg shadow-lg rounded-pill d-md-none mt-3 px-4 py-2 text-white fw-bold d-flex align-items-center justify-content-center"
									href="{{route('site.appoinment.booking')}}">
									<i class="fas fa-clock me-2"></i> {{translate('New Booking')}}
								 </a>
								</div>

							</div>
							<ul class="nav flex-column pt-3">
								<li class="nav-item pl-3"><a href="{{route('site.client.profile')}}" class="nav-link"><i class="fa fa-user client-menu-icon"></i> {{translate('Profile')}}</a></li>
								<li class="nav-item pl-3"><a href="{{route('client.dashboard')}}" aria-current="page" class="nav-link"><i class="fa fa-home client-menu-icon"></i> {{translate('Dashboard')}}</a></li>
								<li class="nav-item pl-3"><a href="{{route('site.client.pending.booking')}}" class="nav-link"><i class="fas fa-clock client-menu-icon"></i> {{translate('Pending Booking')}}</a></li>
								<li class="nav-item pl-3"><a href="{{route('site.client.done.booking')}}" class="nav-link"><i class="fa fa-check-circle client-menu-icon"></i> {{translate('Done Booking')}}</a></li>
								<li class="nav-item pl-3"><a href="{{route('site.client.order.index')}}" class="nav-link"><i class="fas fa-shopping-cart client-menu-icon"></i> {{translate('Orders')}}</a></li>
								<li class="nav-item pl-3"><a href="#" onclick="event.preventDefault(); document.getElementById('logout-form').submit();" class="nav-link"><i class="fas fa-sign-out-alt client-menu-icon"></i> {{translate('Sign Out')}}</a></li>
								<form id="logout-form" action="{{ route('logout') }}" method="POST" class="d-none">
									@csrf
								</form>
							</ul>
						</div>
					</div>
				</div>
			</div>

			<div class="col-md-9">
				@yield('content-site-dashboard')
			</div>
		</div>

	</div>


</div>


<!-- Modal -->
<div class="modal fade" id="chargeCardModal" tabindex="-1" aria-labelledby="chargeCardLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" id="chargeCardLabel">{{translate('Charge Your Card')}}</h5>
				<button type="button" class="btn btn-secondary" data-dismiss="modal" aria-label="Close" onclick="hideAddBalanceModal()">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>
			<div class="modal-body">



				<!-- Modal body content here (form, inputs, etc.) -->
				<form method="post" action="{{ route('charge-card') }}" enctype="multipart/form-data">
					@csrf
					<!-- Add your form fields here -->
					<div class="form-group">
						<label for="card_number">{{translate('Card Number')}}</label>
						<input type="text" class="form-control" id="card_number" placeholder="{{translate('Enter card number')}}" name="code">
					</div>
					<br><br>
					<button type="submit" class="btn btn-primary">{{translate('Save Change')}}</button>
					<button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="hideAddBalanceModal()">{{translate('Close')}}</button>
				</form>
			</div>
		</div>
	</div>
</div>



@push("scripts")
<script src="{{ dsAsset('site/js/custom/client/site-dashboard.js') }}"></script>

<script>
	console.log("Hello world!");

	function showAddBalanceModal() {

		$('#chargeCardModal').modal('show'); // This will trigger the modal manually
	};

	function hideAddBalanceModal() {

		$('#chargeCardModal').modal('hide'); // This will trigger the modal manually
	};
</script>

<!-- Datatables -->
<script src="{{ dsAsset('js/lib/DataTables/datatables.min.js') }}"></script>
@endpush

@endsection