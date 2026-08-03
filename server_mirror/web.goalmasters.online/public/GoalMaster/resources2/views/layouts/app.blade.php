<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta content='width=device-width, initial-scale=1.0, shrink-to-fit=no' name='viewport' />
    <meta name="_token" content="{{ csrf_token() }}" url="{{ url('/') }}" />
    <title>{{$appearance->app_name}} | Admin</title>
    <link rel="shortcut icon" href="{{url($appearance->icon)}}">
    <audio id="notification-sound" src="{{ asset('sounds/videoplayback.mp3') }}" preload="auto"></audio>
    <!-- Fonts and icons -->
    <script src="{{ dsAsset('js/lib/assets/js/plugin/webfont/webfont.min.js') }}"></script>
    <script>
        WebFont.load({
            google: {
                "families": ["Cairo:300,400,700,900"] // تغيير الخط إلى كايرو
            },
            custom: {
                "families": ["Cairo", "Font Awesome 5 Solid", "Font Awesome 5 Regular",
                    "Font Awesome 5 Brands", "simple-line-icons"
                ],
                urls: ["{{ url('/') }}/js/lib/assets/css/fonts.min.css"]
            },
            active: function() {
                sessionStorage.fonts = true;
            }
        });
    </script>
    <style>
        .details {
            font-weight: normal !important;
            direction: rtl !important;
            text-align: right !important;
            cursor: pointer !important;
            color: #31CE36 !important;
            font-size: .75rem !important;
            display: block;
            margin-top: 5px;
        }

        .details:hover {
            background-color: inherit !important;
            color: red !important;
        }

        .notif-content {
            padding: 5px 8px;
            text-align: right;
            background-color: white;
            direction: rtl;
            font-weight: normal;
            font-size: 16px;
            margin-bottom: 5px;
        }

        .notif-content .time {
            font-size: 12px;
            display: block;
            text-align: left;
            direction: ltr;
            font-weight: normal;
            color: #606060;
        }

        .unread {
            background-color: #F2F2F2;
            color: black;
        }
    </style>
</head>


<!-- CSS Files -->
<link href="{{ dsAsset('js/lib/assets/css/bootstrap.min.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/DataTables/datatables.min.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/assets/css/atlantis.min.css') }}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/assets/css/checkbox-slider.css')}}" rel="stylesheet" />
<link href="{{ dsAsset('js/lib/xd-dpicker/jquery.datetimepicker.css')}}" rel="stylesheet" />
<link href="{{ dsAsset('css/site.css?v=1') }}" rel="stylesheet" />
<!-- tel input css -->
<link href="{{dsAsset('js/lib/tel-input/css/intlTelInput.css')}}" rel="stylesheet" />

<!-- bootstrap select -->
<link href="{{dsAsset('js/lib/bootstrap-select-1.13.14/css/bootstrap-select.min.css')}}" rel="stylesheet" />


@stack('adminCss')
</head>


<body data-user-id="{{ Auth::id() }}">
    <div id="process_notifi" class="wrapper">
        <div class="main-header">
            <!-- Logo Header -->
            <div class="logo-header" data-background-color="blue">

                <a href="{{route('home')}}" class="logo">
                    <img height="30" width="145" src="{{url($appearance->logo)}}" alt="navbar brand" class="navbar-brand br-5 bg-white" />
                </a>
                <button class="navbar-toggler sidenav-toggler ml-auto" type="button" data-toggle="collapse" data-target="collapse" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon">
                        <i class="icon-menu"></i>
                    </span>
                </button>
                <button class="topbar-toggler more">
                    <i class="icon-options-vertical"></i>
                </button>
                <div class="nav-toggle">
                    <button class="btn btn-toggle toggle-sidebar">
                        <i class="icon-menu"></i>
                    </button>
                </div>
            </div>
            <!-- End Logo Header -->

            <!-- Navbar Header -->
            <nav class="navbar navbar-header navbar-expand-lg" data-background-color="blue2">

                <div class="container-fluid">
                    <div class="collapse" id="search-nav">
                        <form class="navbar-left navbar-form nav-search mr-md-3">
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <button type="submit" class="btn btn-search pr-1">
                                        <i class="fa fa-search search-icon"></i>
                                    </button>
                                </div>
                                <input type="text" placeholder="{{translate('Search')}} ..." class="form-control" />
                            </div>
                        </form>
                    </div>
                    <ul class="navbar-nav topbar-nav ml-md-auto align-items-center">
                        <!--
                        <form id="language-change-form" class="float-start" action="{{ route('change.language') }}" method="POST">
                            @csrf
                            <select id="cmbLang" class="me-3" name="lang_id">
                                @foreach ($language as $lang)
                                <option {{(Session::get('lang')!=null) && (Session::get('lang')['id'])==$lang->id?"selected":""}} value={{$lang->id}}>{{$lang->name}}</option>
                                @endforeach
                            </select>
                        </form>
                        -->

                        <li class="nav-item toggle-nav-search hidden-caret">
                            <a class="nav-link" data-toggle="collapse" href="#search-nav" role="button" aria-expanded="false" aria-controls="search-nav">
                                <i class="fa fa-search"></i>
                            </a>
                        </li>
                        @php
                        $Notifications = Auth::user()->notifications()->where('read_at', null)->latest('created_at')->take(15)->get();
                        use Illuminate\Support\Facades\Auth;
                        $unreadNotifications = Auth::user()->unreadNotifications();
                        $unreadCount = $unreadNotifications->count();
                        @endphp
                        <!-- $id=json_encode($Notifications[0]->data['id']); -->
                        <!-- dd($Notifications[0]->data); -->
                        <!-- dd($data); -->
                        <!-- dd(Auth::id()); -->

                        <li class="nav-item dropdown hidden-caret">
                            <a class="nav-link dropdown-toggle" href="#" id="notifDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fa fa-bell"></i>
                                <span class="notification" id="notification-count">{{$unreadCount}}</span>
                            </a>
                            <ul class="dropdown-menu notif-box animated fadeIn" aria-labelledby="notifDropdown">
                                <li>
                                    <div class="dropdown-title" id="notification-title">
                                        You have {{$unreadCount}} new Notifications
                                    </div>
                                </li>
                                <li style="text-align: center;">
                                    <button type="button" class="btn btn-primary btn-sm m-1" id="markAllAsReadBtn">Mark All as Read</button>
                                </li>
                                <li>
                                    <div class="notif-center" id="notification-list" style="max-height: 300px; overflow-y: auto;">
                                        @foreach ($Notifications as $notification)
                                        @php
                                        $id = isset($notification->data['id']) ? json_encode($notification->data['id']) : null;
                                        @endphp
                                        @if($notification->unread())
                                        <div class="notif-content unread">
                                            <span class="block">
                                                {{ ($notification->data['message']) }}
                                            </span>
                                            @if($id)
                                         
                                            <a class="details" onclick="fetchBookingDetails('{{ $id }}'); markNotificationAsRead('{{ $notification->id }}', this)">
                                                عرض تفاصيل الحجز >>
                                            </a>
                                                                                        @endif
                                            <span class="time">{{ $notification->created_at->diffForHumans() }}</span>
                                        </div>
                                        @else
                                        <div class="notif-content">
                                            <span class="block">
                                                {{ ($notification->data['message']) }}
                                            </span>
                                            @if($id)
                                            <a class="details" onclick="fetchBookingDetails('{{ $id }}')">عرض تفاصيل الحجز >></a>
                                            @endif
                                            <span class="time">{{ $notification->created_at->diffForHumans() }}</span>
                                        </div>
                                        @endif
                                        @endforeach
                                    </div>
                                </li>
                                <li>
                                    <a class="see-all" href="{{route('notifications.view')}}">
                                        {{ translate('See all notifications') }}
                                        <i class="fa fa-angle-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </li>
                        <li class="nav-item dropdown hidden-caret">
                            <a class="nav-link" data-toggle="dropdown" href="#" aria-expanded="false">
                                <i class="fas fa-layer-group"></i>
                            </a>
                            <div class="dropdown-menu quick-actions quick-actions-info animated fadeIn">
                                <div class="quick-actions-header">
                                    <span class="title mb-1">{{translate('Quick Actions')}}</span>
                                    <span class="subtitle op-8">{{translate('Shortcuts')}}</span>
                                </div>
                                <div class="quick-actions-scroll scrollbar-outer">
                                    <div class="quick-actions-items">
                                        <div class="row m-0">
                                            <a class="col-6 col-md-4 p-0" href="{{route('booking.calendar')}}">
                                                <div class="quick-actions-item">
                                                    <i class="flaticon-calendar"></i>
                                                    <span class="text">{{translate('Booking Calendar')}}</span>
                                                </div>
                                            </a>
                                            <a class="col-6 col-md-4 p-0" href="{{route('service.booking.info')}}">
                                                <div class="quick-actions-item">
                                                    <i class="flaticon-list"></i>
                                                    <span class="text">{{translate('Booking Information')}}</span>
                                                </div>
                                            </a>
                                            <a class="col-6 col-md-4 p-0" href="{{route('customer')}}">
                                                <div class="quick-actions-item">
                                                    <i class="flaticon-plus"></i>
                                                    <span class="text">{{translate('Create New Customer')}}</span>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </li>
                        <li class="nav-item dropdown hidden-caret">
                            <a class="dropdown-toggle profile-pic" data-toggle="dropdown" href="#" aria-expanded="false">
                                <div class="avatar-sm">
                                    @if($userInfo['photo']==null || $userInfo['photo']=='')
                                    <img src="{{ dsAsset('js/lib/assets/img/avater-man.png') }}" alt="image profile" class="avatar-img rounded-circle" />
                                    @else
                                    <img src="{{ dsAsset($userInfo['photo']) }}" alt="image profile" class="avatar-img rounded-circle" />
                                    @endif
                                </div>
                            </a>
                            <ul class="dropdown-menu dropdown-user animated fadeIn">
                                <div class="dropdown-user-scroll scrollbar-outer">
                                    <li>
                                        <div class="user-box">
                                            <div class="avatar-lg">
                                                @if($userInfo['photo']==null || $userInfo['photo']=='')
                                                <img src="{{ dsAsset('js/lib/assets/img/avater-man.png') }}" alt="image profile" class="avatar-img rounded" />
                                                @else
                                                <img src="{{ dsAsset($userInfo['photo']) }}" alt="image profile" class="avatar-img rounded" />
                                                @endif
                                            </div>
                                            <div class="u-text">
                                                <h4>{{ $userInfo['username'] }}</h4>
                                                {{-- <p class="text-muted">{{ $userInfo['email'] }}</p> --}}
                                                <a href="{{route('change.user.profile.photo')}}" class="btn btn-xs btn-secondary btn-sm">{{translate('Change Photo')}}</a>
                                            </div>
                                        </div>
                                    </li>
                                    <li>

                                        <div class="dropdown-divider"></div>
                                        <a class="dropdown-item" href="{{ route('change.user.password') }}">{{translate('Change Password')}}</a>
                                        <div class="dropdown-divider"></div>
                                        <a class="dropdown-item" id="app-logout" href="{{ route('logout') }}">{{translate('Logout')}}</a>
                                    </li>
                                    <form id="logout-form" action="{{ route('logout') }}" method="POST" class="d-none">
                                        @csrf
                                    </form>
                                </div>
                            </ul>
                        </li>
                    </ul>
                </div>
            </nav>
            <!-- End Navbar -->
        </div>
        <!-- Sidebar -->
        <div class="sidebar sidebar-style-2">

            <div class="sidebar-wrapper scrollbar scrollbar-inner">
                <div class="sidebar-content">
                    <div class="user">
                        <div class="avatar-sm float-left mr-2">
                            @if($userInfo['photo']==null || $userInfo['photo']=='')
                            <img src="{{ dsAsset('js/lib/assets/img/avater-man.png') }}" alt="image profile" class="avatar-img rounded-circle" />
                            @else
                            <img src="{{ dsAsset($userInfo['photo']) }}" alt="image profile" class="avatar-img rounded-circle" />
                            @endif

                        </div>
                        <div class="info">
                            <a data-toggle="collapse" href="#collapseExample" aria-expanded="true">
                                <span>
                                    {{$userInfo['name'] }}
                                    {{-- <span class="user-level">{{ $userInfo['email'] }}</span> --}}
                                </span>
                            </a>
                            <div class="clearfix"></div>
                        </div>
                    </div>
                    <ul class="nav nav-primary">

                        @foreach ($menuList->where('level', 1) as $item)
                        <li class="nav-item">
                            <a data-toggle="collapse" href="#base{{ $item->id }}" class="collapsed" aria-expanded="false">
                                <i class="{{ $item->icon }}"></i>
                                <p>{{ translate($item->display_name) }}</p>
                                <span class="caret"></span>
                            </a>
                            <div class="collapse" id="base{{ $item->id }}">
                                <ul class="nav nav-collapse">
                                    @foreach ($menuList->where('level', 2)->where('resource_id', $item->id) as $item1)
                                    
                                    <!-- for hide dott item and department item -->
                                    @if (!($item1->display_name=='Salary' || $item1->display_name=='Department') ||$item1->display_name=='forgivingGenerous')
                                    <li>
                                        <a href="{{ route($item1->method) }}">
                                            <span class="sub-item"> {{ translate($item1->display_name) }}</span>
                                        </a>
                                    </li>

                                    @endif
                                    @endforeach
                                </ul>
                            </div>
                        </li>
                        @endforeach

                    </ul>
                </div>
            </div>
        </div>
        <div class="main-panel">
            <div class="content">
                @yield('content')
            </div>
        </div>

    </div>
    <!-- Schedule Details View Modal -->
    <div class="modal fade details-view-modal" id="modalViewScheduleDetails" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header d-none">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="col-md-12">
                        <div id="task-details-body-wrap">
                            <div id="task-details-body-wrap-user">
                                <div style="width: 60px; height:60px; border-radius:50%; overflow:hidden;">
                                    <img id="scheduleEmployeeImage" src="" alt="user image" width="100%">
                                </div>
                                <h4 id="scheduleEmployee"></h4>
                                <p id="scheduleSpecialist"></p>
                            </div>
                            <div id="task-details-body-wrap-task" dir="rtl" style="text-align: right;">
                                <p>{{translate('Booking No')}} : <span id="scheduleServiceId"></span></p>
                                <p>{{translate('Branch')}}: <span id="scheduleBranch"></span></p>
                                <p>{{translate('Customer Name')}}: <span id="scheduleCustomer"></span></p>
                                <p>{{translate('Customer Phone')}}: <span id="scheduleCustomerPhone"></span></p>
                                <p>{{translate('Service Date')}}: <span id="scheduleServiceDate"></span></p>
                                <p>{{translate('Service')}}: <span id="scheduleService"></span></p>
                                <p>{{translate('Service Time')}}: <span id="scheduleServiceTime"></span></p>
                                <p>{{translate('Paid Amount')}}: <span id="schedulePaidAmount"></span></p>
                                <p style="margin-bottom: 0;">{{translate('Status')}} : <span id="scheduleServiceStatus"></span></p>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="bookingId" style="direction: rtl; margin-bottom: 10px;">
                    <form onsubmit="event.preventDefault(); changeBookingStatus();" class="d-flex justify-content-around">
                        <div class="me-2">
                            <select id="bookingStatusSelect" class="form-control form-control-sm">
                                <option value="" disabled selected> تغيير حالة الحجز</option>
                                <option value="0">غير خالص</option>
                                <option value="1">بانتظار قبول الطلب</option>
                                <option value="2">موافق عليه</option>
                                <option value="3">إلغاء</option>
                                <option value="4">خالص</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary btn-sm">حفظ</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!--Jquery JS-->
    <script src="{{ dsAsset('js/lib/assets/js/core/jquery-3.6.0.min.js') }}"></script>
    <link href="https://fonts.googleapis.com/css?family=Exo:500,600,700|Roboto&display=swap" rel="stylesheet" />

    <!--   Core JS Files   -->
    <script src="{{ dsAsset('js/lib/assets/js/core/popper.min.js') }}"></script>
    <script src="{{ dsAsset('js/lib/assets/js/core/bootstrap.min.js') }}"></script>

    <!-- jQuery UI -->
    <script src="{{ dsAsset('js/lib/assets/js/plugin/jquery-ui-1.12.1.custom/jquery-ui.min.js') }}"></script>
    <script src="{{ dsAsset('js/lib/assets/js/plugin/jquery-ui-touch-punch/jquery.ui.touch-punch.min.js') }}"></script>

    <!-- jQuery Scrollbar -->
    <script src="{{ dsAsset('js/lib/assets/js/plugin/jquery-scrollbar/jquery.scrollbar.min.js') }}"></script>

    <!-- Datatables -->
    <script src="{{ dsAsset('js/lib/DataTables/datatables.min.js') }}"></script>

    <!--theam JS -->
    <script src="{{ dsAsset('js/lib/assets/js/atlantis.js') }}"></script>

    <!--notify JS-->
    <script src="{{ dsAsset('js/lib/assets/js/plugin/bootstrap-notify/bootstrap-notify.min.js') }}"></script>

    <!--JQ bootstrap validation-->
    <script src="{{ dsAsset('js/lib/assets/js/plugin/jquery-bootstrap-validation/jqBootstrapValidation.js') }}"></script>

    <!--site js-->
    <script src="{{ dsAsset('js/site.js') }}"></script>
    <script src="{{ dsAsset('js/lib/js-manager.js') }}"></script>
    <script src="{{ dsAsset('js/lib/js-message.js') }}"></script>

    <!-- bootstrap select -->
    <script src="{{ dsAsset('js/lib/bootstrap-select-1.13.14/js/bootstrap-select.min.js') }}"></script>

    <!-- datetime pciker js -->
    <script src="{{ dsAsset('js/lib/xd-dpicker/build/jquery.datetimepicker.full.min.js') }}"></script>
    <script src="{{ dsAsset('js/lib/moment.js') }}"></script>

    <!-- tel input -->
    <script src="{{ dsAsset('js/lib/tel-input/js/intlTelInput.js') }}"></script>
    @stack('adminScripts')

    <script src="https://js.pusher.com/8.2.0/pusher.min.js"></script>
    
    <script>
        const now = new Date();
        // import moment from 'moment';
        // var currentUserId = {{Auth::id()}}; /////////
        const currentUserId = document.body.getAttribute('data-user-id');

        // console.log(currentUserId);

        // Initialize Pusher
        // Pusher.logToConsole = true;
        var pusher = new Pusher('d1cfa633dce87f8efe80', {
            cluster: 'eu'
        });

        // Subscribe to the channel
        // const channel = pusher.subscribe('admin-notifications');
        const channel = pusher.subscribe('admin-notifications.' + currentUserId);

        channel.bind('CardCharged', function(data) {
            // Update notification count
            const notificationCountElem = document.getElementById('notification-count');
            let notificationCount = parseInt(notificationCountElem.textContent) || 0;
            notificationCountElem.textContent = notificationCount + 1;

            // Update the notification title
            const notificationTitleElem = document.getElementById('notification-title');
            notificationTitleElem.textContent = `You have ${notificationCount + 1} new notifications`;

            // Append the new notification to the notification list
            const notificationListElem = document.getElementById('notification-list');
            const notificationContent = document.createElement('div');
            notificationContent.classList.add('notif-content', 'unread');

            // Set the message and time
            notificationContent.innerHTML = `
            <span class="block">${data.message}</span>
            <span class="time">${data.created_at}</span>
        `;
            notificationListElem.prepend(notificationContent);
            
        });

        // Listen for the BookingCreated event
        channel.bind('bookingCreated', function(data) {
            // Update notification count
            const notificationCountElem = document.getElementById('notification-count');
            let notificationCount = parseInt(notificationCountElem.textContent) || 0;
            document.getElementById("notification-sound").play();

            // زيادة العداد
            notificationCountElem.textContent = notificationCount + 1;           

            // Update the notification title
            const notificationTitleElem = document.getElementById('notification-title');
            notificationTitleElem.textContent = `You have ${notificationCount + 1} new notifications`;

            // Append the new notification to the notification list
            const notificationListElem = document.getElementById('notification-list');
            const notificationContent = document.createElement('div');
            notificationContent.classList.add('notif-content', 'unread');

            // Set the message and time
            notificationContent.innerHTML = `
                <span class="block">${data.message}</span>
                <a class="details" onclick="fetchBookingDetails(${data.id})">
                عرض تفاصيل الحجز >> </a>              
                <span class="time">${data.created_at}</span>
            `;

            // إضافة حدث click لتحديث حالة الإشعار
            notificationContent.addEventListener('click', function() {
                markNotificationAsRead(data.id); 
                notificationContent.classList.remove('unread'); // إزالة class "unread"
                notificationCountElem.textContent = notificationCount; // تحديث العداد
            });

            notificationListElem.prepend(notificationContent);
        });

        channel.bind('bookingChanged', function(data) {
            // Update notification count
            const notificationCountElem = document.getElementById('notification-count');
            let notificationCount = parseInt(notificationCountElem.textContent) || 0;
            notificationCountElem.textContent = notificationCount + 1;

             if (notificationCount < parseInt(notificationCountElem.textContent)) {
                const notificationSound = document.getElementById('notification-sound');
                notificationSound.play();
            }
            // Update the notification title
            const notificationTitleElem = document.getElementById('notification-title');
            notificationTitleElem.textContent = `You have ${notificationCount + 1} new notifications`;

            // Append the new notification to the notification list
            const notificationListElem = document.getElementById('notification-list');
            const notificationContent = document.createElement('div');
            notificationContent.classList.add('notif-content', 'unread');

            // Set the message and time
            notificationContent.innerHTML = `
            <span class="block">${data.message}</span>
            <a class="details" onclick="fetchBookingDetails(${data.id})">عرض تفاصيل الحجز >></a>
            <span class="time">${data.created_at}</span>
        `;
            notificationListElem.prepend(notificationContent);
        });
    </script>
   
   <script>
        $(document).ready(function() {
            $('#markAllAsReadBtn').click(function() {
                $.ajax({
                    url: `{{route('notifications.markAsRead')}}`,
                    type: 'POST',
                    data: {
                        _token: '{{ csrf_token() }}',
                    },
                    success: function(response) {
                        if (response.status === 'success') {
                            console.log('Notifications marked as read successfully');
                            $('.notif-content.unread').removeClass('unread');
                            $('#notification-count').text(0);
                            $('#notification-title').text('You have 0 new Notifications');
                            localStorage.setItem("unreadNotifications", 0);
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Error marking notifications as read:', error);
                    }
                });
            });
        });

     

        function fetchBookingDetails(serviceId) {
            function updateServiceStatus(data) {
                // Define the mapping of status codes to names within the function
                const statusName = (() => {
                    switch (data.data && data.data.status) {
                        case 0:
                            return 'غير خالص';
                        case 1:
                            return 'بانتظار قبول الطلب';
                        case 2:
                            return 'موافق عليه';
                        case 3:
                            return 'إلغاء';
                        case 4:
                            return 'خالص';
                        default:
                            return 'N/A';
                    }
                })();
                return statusName;
            }

            // Make an AJAX call to fetch booking details
            fetch(`/get-booking-info-by-service-id?sch_service_booking_id=${serviceId}`)
                .then(response => response.json())
                .then(data => {
                    const statusName = updateServiceStatus(data);
                    // Populate the modal content with the new structure
                    document.getElementById('scheduleEmployeeImage').src = data.data.image_url || ''; // Adjust as needed
                    document.getElementById('scheduleServiceId').innerText = data.data.id || 'N/A'; // Adjust according to your data structure
                    document.getElementById('scheduleEmployee').innerText = data.data.employee || 'N/A'; // Adjust according to your data structure
                    document.getElementById('scheduleSpecialist').innerText = data.data.specialist || 'N/A'; // Adjust as needed
                    document.getElementById('scheduleBranch').innerText = data.data.branch || 'N/A';
                    document.getElementById('scheduleCustomer').innerText = data.data.customer || 'N/A';
                    document.getElementById('scheduleCustomerPhone').innerText = data.data.phone_no || 'N/A';
                    // {{-- document.getElementById('scheduleCustomerEmail').innerText = data.data.email || 'N/A'; --}}
                    document.getElementById('scheduleServiceDate').innerText = data.data.date || 'N/A';
                    document.getElementById('scheduleService').innerText = data.data.service || 'N/A';
                    document.getElementById('scheduleServiceTime').innerText = data.data.start_time ? JsManager.MomentTime(data.data.start_time).format('h:mm A') : 'N/A';
                    document.getElementById('schedulePaidAmount').innerText = data.data.paid_amount || 'N/A';
                    document.getElementById('scheduleServiceStatus').innerText = statusName || 'N/A';
                    document.getElementById('bookingId').setAttribute('data-id', data.data.id);
                    document.getElementById('bookingId').setAttribute('data-status', data.data.status);
                    // Show the modal
                    const bookingModal = new bootstrap.Modal(document.getElementById('modalViewScheduleDetails'));
                    bookingModal.show();
                })
                .catch(error => console.error('Error fetching booking details:', error));
        };

        function changeBookingStatus() {
            JsManager.StartProcessBar();

            // Retrieve booking ID and selected status
            const bookingId = document.getElementById('bookingId').dataset.id;
            const statusValue = document.getElementById('bookingStatusSelect').value; // Get selected value

            // Prepare JSON payload
            const jsonParam = {
                booking_id: bookingId,
                status: statusValue // Pass the status value directly
            };

            // Log for debugging
            console.log("Booking ID:", bookingId);
            console.log("Selected Status Value:", statusValue);

            // API endpoint for updating booking status
            const serviceUrl = "change-service-booking-status";

            // Send the JSON payload using JsManager
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

            // Success callback
            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    Message.Success("Successfully update service status to " + ServiceStatus(statusValue));
                    setTimeout(() => {location.reload();}, 1000);
                } else {
                    Message.Error("Failed to update service status for " + ServiceStatus(statusValue));
                }
                JsManager.EndProcessBar();
            }

            // Failure callback
            function onFailed(xhr, status, err) {
                console.error("Error updating status:", err);
                JsManager.EndProcessBar();
            }
        };

        function ServiceStatus(status) {
            var serviceStatus = ['غير خالص', 'بانتظار قبول الطلب', 'موافق عليه', 'إلغاء', 'خالص'];
            return serviceStatus[status];
        }
        function enforceMinMax(el) {
            if (el.value != "") {
                if (parseInt(el.value) < parseInt(el.min)) {
                    el.value = el.min;
                }
                if (parseInt(el.value) > parseInt(el.max)) {
                    el.value = el.max;
                }
            }
        }
   
        function markNotificationAsRead(id, element) {

    fetch(`{{ route('notifications.markAsRead.one', ['id' => 'PLACEHOLDER']) }}`.replace('PLACEHOLDER', id), {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': '{{ csrf_token() }}'
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {

            let notificationCountElement = document.getElementById('notification-count');
            let notificationTitleElement = document.getElementById('notification-title');

            let currentCount = parseInt(notificationCountElement.textContent);

            if (currentCount > 0) {
                let newCount = currentCount - 1;
                notificationCountElement.textContent = newCount;

                if (newCount > 0) {
                    notificationTitleElement.textContent = `You have ${newCount} new Notifications`;
                } else {
                    notificationTitleElement.textContent = 'You have 0 new Notifications';
                }
            }

            if (element) {
                element.closest('.notif-content').classList.remove('unread');
            }
             oldCount  = localStorage.getItem("unreadNotifications"); 
             localStorage.setItem("unreadNotifications", oldCount - 1 );

        }
    })
    .catch(error => console.error('Error marking notification as read:', error));
}

   
   </script>




    <!-- Check Notfication --->
    <script>
        'use strict';
    
        let previousUnreadCount = localStorage.getItem("unreadNotifications") || 0;
        console.log(previousUnreadCount);
        
        let userInteracted = false;
    
        document.addEventListener("click", () => userInteracted = true, { once: true });
    
        function checkForNewNotifications() {
            fetch("{{ route('notifications.count') }}")
                .then(response => response.json())
                .then(data => {
                    let currentUnreadCount = data.unreadCount;
                    
                    if (userInteracted && currentUnreadCount > previousUnreadCount) {
                        playNotificationSound();
                        previousUnreadCount = currentUnreadCount; //? Update the previous count
                    }
    
                    localStorage.setItem("unreadNotifications", currentUnreadCount);
                })
                .catch(error => console.error("Error fetching notifications:", error));
        }
    
        function playNotificationSound() {
            const audio = new Audio('{{ asset('sounds/videoplayback.mp3') }}');
            audio.play().catch(error => console.error('Error playing sound:', error));
        }
    
        setInterval(checkForNewNotifications, 1000);
    </script>

</body>

</html>