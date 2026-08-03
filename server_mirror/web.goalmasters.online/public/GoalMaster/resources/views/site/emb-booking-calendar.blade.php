<!DOCTYPE html>
<html lang="zxx" class="no-js" dir="{{$rtl}}">

<head>
    <meta name="_token" content="{{ csrf_token() }}" url="{{ url('/') }}" />
    <!-- Mobile Specific Meta -->
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- Favicon-->
    <link rel="shortcut icon" href="{{url($appearance->icon)}}">
    <!-- Meta Description -->
    <meta name="description" content="{{$appearance->meta_description}}">
    <!-- Meta Keyword -->
    <meta name="keywords" content="{{$appearance->meta_keywords}}">
    <!-- meta character set -->
    <meta charset="UTF-8">
    <!-- Site Title -->
    <title>{{$appearance->app_name}}</title>


    <link rel="stylesheet" href="{{dsAsset('site/assets/css/bootstrap.min.css')}}">
    <link rel="stylesheet" href="{{dsAsset('site/assets/js/lib/icofont/icofont.min.css')}}">
    <link rel="stylesheet" href="{{dsAsset('site/assets/js/lib/fontawesome/css/all.min.css')}}">
    <link rel="stylesheet" href="{{dsAsset('site/assets/js/lib/owl-carousel/assets/owl.theme.default.min.css')}}">
    <link rel="stylesheet" href="{{dsAsset('site/assets/js/lib/owl-carousel/assets/owl.carousel.min.css')}}">
    <link rel="stylesheet" href="{{dsAsset('site/assets/js/lib/magnific-popup/magnific-popup.css')}}">
    <link rel="stylesheet" href="{{dsAsset('site/assets/css/app.css')}}">
    <link href="{{dsAsset('js/lib/xd-dpicker/jquery.datetimepicker.css')}}" rel="stylesheet" />
    <link href="{{dsAsset('js/lib/tel-input/css/intlTelInput.css')}}" rel="stylesheet" />


    <style>
        body{
            background: transparent;
        }
        :root {
		--theamColor: {{$appearance["theam_color"]}};
		--theamHoverColor: {{$appearance["theam_hover_color"]}};
		--theamActiveColor: {{$appearance["theam_active_color"]}};
		--theamMenuColor: {{$appearance["menu_color"]}};
		--theamMenuColor2: {{$appearance["menu_color2"]}};
		--theamColorRgba:{{hex2Rgba($appearance["theam_color"],0.1)}};
	}
    </style>

    @stack('css')
</head>

<body id="process_notifi">
    <!-- Button trigger modal -->


    <!-- Start booking Area -->
    <section class="appoinment-booking-area-p">
        <div class="container-fluid">
            <div class="row">
                <div class="col-lg-12">
                    <div class="single-booking-area">
                        <form class="form-wrap" id="formServiceBooking">
                            <div id="serviceStep">
                                <h3>{{translate('Service')}}</h3>
                                <section>
                                    <div class="row">
                                        <div class="col-md-3">
                                            <label for="cmn_branch_id" class="float-start">{{translate('Branch')}}</label>
                                            <select id="cmn_branch_id" name="cmn_branch_id" class="serviceInput form-control">

                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="sch_service_category_id" class="float-start">{{translate('Category')}}</label>
                                            <select id="sch_service_category_id" name="sch_service_category_id" class="serviceInput form-control">

                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="sch_service_id" class="float-start">{{translate('Service')}}</label>
                                            <select id="sch_service_id" name="sch_service_id" class="serviceInput form-control">

                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label for="sch_employee_id" class="float-start">{{translate('Staff')}}</label>
                                            <select id="sch_employee_id" name="sch_employee_id" class="serviceInput form-control">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-auto col-lg-auto col-sm-auto" id="divServiceCalendar">
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <label for="serviceDate" class="float-start">{{translate('Service Date')}}</label>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <input id="serviceDate" name="service_date" class="form-control input-sm" type="text" readonly />
                                                    <div id="divServiceDate" style="float: left;"></div>
                                                </div>
                                            </div>

                                        </div>
                                        <div class="col">
                                            <div id="divTopDays">
                                                <div class="row">
                                                    <div class="col-md-12">
                                                        <div class="float-start" id="divDaysName"></div>
                                                        <div class="float-end" id="divPreNext">
                                                            <i id="iPrvDate" title="Previous day" class="iChangeDate fa fa-chevron-left float-start"></i>
                                                            <i id="iNextDate" title="Next day" class="iChangeDate fa fa-chevron-right float-end"></i>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row divServiceAvaiable">
                                                    <div class="col-md-12" id="divServiceAvaiableTime">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col divSelectedService">
                                            <i class="fa fa-calendar float-start pl-2 mt-1 mr-1" aria-hidden="true"></i>
                                            <i id="iSelectedServiceText" class=""></i>
                                        </div>
                                        <div class="col-md-auto col-lg-auto col-sm-auto float-end">
                                            <button type="button" class="btn btn-success float-end" id="add-service-btn"><i class="fas fa-plus-circle"></i> {{translate('Add more service')}}</button>
                                        </div>
                                        <div class="col-md-12 mt-3">
                                            <table id="tbl-service-cart" class="table table-responsive table-bordered fs-13 text-start d-none">
                                                <thead>
                                                    <tr>
                                                        <th>{{translate('SL')}}</th>
                                                        <th>{{translate('Service')}}</th>
                                                        <th>{{translate('Staff')}}</th>
                                                        <th>{{translate('Date')}}</th>
                                                        <th>{{translate('Time')}}</th>
                                                        <th>{{translate('Fee')}}</th>
                                                        <th class="text-center">{{translate('Opt')}}</th>
                                                    </tr>
                                                </thead>
                                                <tbody class="text-start" id="iSelectedServiceList"></tbody>
                                            </table>
                                        </div>
                                    </div>
                                </section>
                                <h3>{{translate('Details')}}</h3>
                                <section>
                                    <div class="row p-1">
                                        <div class="col-md-12">
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <label for="full_name" class="float-start">{{translate('Full Name')}} *</label>
                                                    <input type="text" id="full_name" name="full_name" class="form-control" />
                                                </div>
                                                <!-- <div class="col-md-4">
                                                    <label for="email" class="float-start">{{translate('Email')}} *</label>
                                                    <input type="email" id="email" name="email" class="form-control" />
                                                </div> -->
                                                <div class="col-md-4">
                                                    <label for="phone_no" class="float-start">{{translate('Phone')}} *</label>
                                                    <input type="tel" id="phone_no" name="phone_no" class="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-12">
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <label for="state" class="float-start">{{translate('State')}}</label>
                                                    <input type="text" id="state" name="state" class="form-control" />
                                                </div>
                                                <div class="col-md-4">
                                                    <label for="city" class="float-start">{{translate('City')}}</label>
                                                    <input type="text" id="city" name="city" class="form-control" />
                                                </div>
                                                <div class="col-md-4">
                                                    <label for="postal_code" class="float-start">{{translate('Postal Code')}}</label>
                                                    <input type="text" id="postal_code" name="postal_code" class="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-12">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <label for="street_address" class="float-start">{{translate('Street Address')}}</label>
                                                    <input type="text" id="street_address" name="street_address" class="form-control" />
                                                </div>
                                                <div class="col-md-6">
                                                    <label for="service_remarks" class="float-start">{{translate('Service Remarks')}}</label>
                                                    <input type="text" id="service_remarks" name="service_remarks" class="form-control" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </section>
                                <h3>{{translate('Pay')}}</h3>
                                <section>
                                    <div class="row mt-3" id="divPaymentType">
                                        <div class="col-md-5 mb-4">
                                            <h6 class="float-start">Choose a way to pay</h6>
                                            <div id="divPaymentMethod" class="w100 float-start">

                                            </div>
                                        </div>
                                        <div class="col-md-7">
                                            <div class="w-100 float-start" id="divOrderSummary">
                                                <h5 class="text-start">{{translate('Order Summary')}}</h5>
                                                <div class="w-100 float-start">
                                                    <div id="divServiceSection" class="w-100 float-start">
                                                        <!-- service list will append here-->

                                                    </div>

                                                    <div class="service-item">
                                                        <div class="float-start">{{translate('Subtotal')}}</div>
                                                        <div class="float-end fw-bold" id="summary-subtotal">0</div>

                                                    </div>
                                                    <div class="service-item" id="summary-discount-parent">
                                                        <div class="float-start">{{translate('Discount')}}</div>
                                                        <div class="float-end fw-bold" id="summary-discount">0</div>
                                                    </div>
                                                    <div class="service-item">
                                                        <div class="float-start w-100 text-start">{{translate('Apply Coupon Code')}}</div>
                                                        <div class="float-start w-100">
                                                            <div class="input-group mb-3">
                                                                <input type="text" name="coupon_code" id="coupon_code" class="form-control" aria-describedby="btn-apply-coupon">
                                                                <button class="btn btn-booking" type="button" id="btn-apply-coupon">{{translate('Apply Coupon')}}</button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="service-item">
                                                        <div class="service-border-button"></div>
                                                        <div class="float-start fw-bold">{{translate('Total Amount')}}</div>
                                                        <div class="float-end fw-bold" id="summary-total">0</div>
                                                    </div>

                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </section>
                                <h3>{{translate('Done')}}</h3>
                                <section>
                                    <div class="color-success p-5">{{translate('Your service booking is completed & service is under processing, Check your WhatsApp.')}}</div>
                                </section>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- End booking Area -->

    <link href="https://fonts.googleapis.com/css?family=Exo:500,600,700|Roboto&display=swap" rel="stylesheet" />
    <script src="{{dsAsset('site/assets/js/jquery.min.js') }}"></script>

        <!-- datetime pciker js -->
        <script src="{{ dsAsset('js/lib/tel-input/js/intlTelInput.js') }}"></script>
    <script src="{{ dsAsset('js/lib/moment.js') }}"></script>
    <script src="{{ dsAsset('js/lib/jquery.steps/jquery.steps.min.js') }}"></script>
    <link href="{{ dsAsset('js/lib/jquery.steps/jquery.steps.css') }}" rel="stylesheet" />
    <link rel="stylesheet" href="{{dsAsset('site/css/website.css')}}">
    <script src="{{dsAsset('site/js/custom/website.js')}}"></script>
    
    <script src="{{dsAsset('site/assets/js/bootstrap.min.js') }}"></script>
    <script src="{{dsAsset('site/assets/js/popper.min.js') }}"></script>
    <script src="{{dsAsset('site/assets/js/easing.js') }}"></script>
    <script src="{{dsAsset('site/assets/js/lib/owl-carousel/owl.carousel.min.js') }}"></script>
    <script src="{{dsAsset('site/assets/js/lib/magnific-popup/jquery.magnific-popup.min.js') }}"></script>
    <script src="{{dsAsset('site/assets/js/main.js') }}"></script>
    <!--notify JS-->
    <script src="{{ dsAsset('js/lib/assets/js/plugin/bootstrap-notify/bootstrap-notify.min.js') }}"></script>
    <!--JQ bootstrap validation-->
    <script src="{{ dsAsset('js/lib/assets/js/plugin/jquery-bootstrap-validation/jqBootstrapValidation.js') }}"></script>
    <script src="{{ dsAsset('js/lib/xd-dpicker/build/jquery.datetimepicker.full.min.js') }}"></script>
    <script src="{{ dsAsset('js/site.js') }}"></script>
    <script src="{{ dsAsset('js/lib/js-manager.js') }}"></script>
    <script src="{{ dsAsset('js/lib/js-message.js') }}"></script>

    
    <link href="{{ dsAsset('site/css/custom/website-booking.css') }}" rel="stylesheet" />
    <script src="{{ dsAsset('site/js/custom/website-booking.js') }}"></script>


</body>

</html>