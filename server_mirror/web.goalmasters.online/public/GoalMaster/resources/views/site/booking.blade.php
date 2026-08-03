@extends('site.layouts.site')
@section('content')
@push("scripts")
<script src="{{ dsAsset('site/js/custom/website-booking.js') }}"></script>
<link href="{{ dsAsset('site/css/custom/website-booking.css') }}" rel="stylesheet" />
@endpush

<style>
    .wizard>.steps>ul>li,
    .wizard>.actions>ul>li {
        float: right !important;
    }
</style>

<!--start banner section -->
<section class="banner-area position-relative" style="background:url({{$appearance->background_image}})no-repeat;">
    <div class="overlay overlay-bg"></div>
    <div class="container">
        <div class="row">
            <div class="col-md-12">
                <div class="position-relative text-center">
                    <h1 class="text-capitalize mb-3 text-white">{{translate('Appointment Booking')}}</h1>
                    <a class="text-white" href="{{route('site.home')}}">{{translate('Home')}} </a>
                    <i class="icofont-long-arrow-right text-white"></i>
                    <a class="text-white" href="{{route('site.appoinment.booking')}}"> {{translate('Appointment Booking')}}</a>
                </div>
            </div>
        </div>
    </div>
</section>
<!-- end banner section -->

<!-- Start bookiing Area -->
<section class="appoinment-booking-area mb-5">
    <div class="container">
        <div class="row">
            <div class="col-lg-4 order-sm-first order-last">
                <div class="single-booking-area single-booking-support mb-3">
                    <div class="mt-3">
                        <div class="support-man-icon mb-3">
                            <i class="icofont-support text-lg"></i>
                        </div>
                        <span class="h3">{{translate('Call for any Emergency Support!')}}</span>
                        <h2 class="text-color mt-3">{{$appearance->contact_phone}}</h2>
                    </div>
                </div>
            </div>
            <div class="col-lg-8 mb-3">
                <div class="single-booking-area">
                    <form class="form-wrap" id="formServiceBooking">
                        <div id="serviceStep">
                            <h3>{{translate('Service')}}</h3>
                            <section>
                                <div class="row">
                                    <div class="col-md-4">
                                        <label for="zone_id" class="float-start">{{translate('Zone')}}</label>
                                        <select id="zone_id" name="zone_id" class="serviceInput form-control">

                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="cmn_branch_id" class="float-start">{{translate('Branch')}}</label>
                                        <select id="cmn_branch_id" name="cmn_branch_id" class="serviceInput form-control">

                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="sch_service_category_id" class="float-start">{{translate('Category')}}</label>
                                        <select id="sch_service_category_id" name="sch_service_category_id" class="serviceInput form-control">

                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="sch_service_id" class="float-start">{{translate('Service')}}</label>
                                        <select id="sch_service_id" name="sch_service_id" class="serviceInput form-control">

                                        </select>
                                    </div>
                                    <div class="col-md-4">
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
                                                <label for="full_name" class="float-start">{{translate('اسمك كاملا')}} *</label>
                                                <input type="text" id="full_name" name="full_name" class="form-control" />
                                            </div>
                                            <div class="col-md-4">
                                                <label for="phone_no" class="float-start">{{translate('Phone')}} *</label>
                                                <input type="text" id="phone_no" name="phone_no" class="form-control" />
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-12">
                                        <div class="row">
                                            <div class="col-md-4" style="display: none;">
                                                <label for="state" class="float-start">{{translate('State')}}</label>
                                                <input type="text" id="state" name="state" class="form-control" />
                                            </div>
                                            <div class="col-md-4" style="display: none;">
                                                <label for="city" class="float-start">{{translate('City')}}</label>
                                                <input type="text" id="city" name="city" class="form-control" />
                                            </div>
                                            <div class="col-md-4" style="display: none;">
                                                <label for="postal_code" class="float-start">{{translate('Postal Code')}}</label>
                                                <input type="text" id="postal_code" name="postal_code" class="form-control" />
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-12">
                                        <div class="row">
                                            <div class="col-md-6" style="display: none;">
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

                            <h3>تأكيد رقم الهاتف</h3>
                            <section>
                                <input type="hidden" id="verification_status">
                                <p id="message" class="text-center"></p>
                                <div id="verified" style="display: none;" class="text-success text-center my-4">
                                    <h4>يمكنك الآن متابعة الحجز</h4>
                                </div>

                                <div class="container" id="not-verified" dir="rtl" style="display: none;">
                                    <div class="card shadow-lg border-0 rounded-3">
                                        <div class="card-body p-4">
                                            <p class="mb-4 fs-5 text-center text-muted">
                                                {{ translate('قبل المتابعة، يرجى التحقق من الواتساب الخاص بك للحصول على كود التحقق.') }}
                                            </p>
                                            <p class="fs-5 text-center">
                                                {{ translate('إذا لم تستلم الكود') }}:
                                            <p class="btn btn-link text-primary text-decoration-none" id="resend">
                                                {{ translate('اضغط هنا لطلب كود جديد') }}
                                            </p>
                                            </p>
                                            <div class="mb-3">
                                                <label for="code" class="form-label fs-5 fw-bold text-end d-block">
                                                    {{ translate('أدخل كود التحقق') }}
                                                </label>
                                                <input type="text" id="code" name="code" class="form-control text-end" placeholder="{{ translate('أدخل الكود هنا') }}" required>
                                                <span id="codeError" class="d-none" style="color: red; font-size: 12px;" >الكود غير صحيح</span>
                                            </div>
                                                <div class="text-center mt-4">
                                                    <p class="btn btn-primary px-4 py-2 fw-bold" id="verify">
                                                        {{ translate('تأكيد') }}
                                                    </p>
                                                </div>
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <h3>{{translate('Pay')}}</h3>
                            <section>
                                <div class="row mt-3" id="divPaymentType">
                                    <div class="col-md-5 mb-4">
                                        <h6 class="float-start">أختر طريقة الدفع المناسبة</h6>
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

@endsection