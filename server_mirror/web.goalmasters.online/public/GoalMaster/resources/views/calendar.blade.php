@extends('layouts.app')
@section('content')
@push("adminScripts")

<script>
  const customers = @json($allcustomers); // Pass the customer data to JavaScript
</script>
<script src="{{dsAsset('js/custom/calendar.js')}}"></script>

<script src="{{dsAsset('js/lib/jquery-schedule-plus/js/jq.schedule.plus.js')}}"></script>
<script src="{{dsAsset('js/custom/booking/booking-calendar.js')}}"></script>
@endpush

@push("adminCss")
<link href="{{ dsAsset('css/custom/booking/booking-calendar.css')}}" rel="stylesheet" />
<link href="{{ dsAsset('css/custom/calendar.css')}}" rel="stylesheet" />
@endpush
<div class="calendar-container">
  <form method="get" action="{{ route('booking.calendar') }}" class="filter-form">
    <div style="margin: 0;" class="row justify-content-around flex-wrap mb-3">
      <select class="form-select col-md-2" aria-label="Default select example" name="branch_id" id="branch_id" onchange="this.form.submit()">
        <option value="" selected>كل اﻹدارات</option>
        @foreach ($branches as $branch)
        <option value="{{ $branch->id }}" {{ $branch->id == $selectedBranch ? 'selected' : '' }}>{{ $branch->name }}</option>
        @endforeach
      </select>

      <select class="form-select col-md-2" name="category_id" id="category_id" onchange="this.form.submit()" {{ $selectedBranch ? '' : 'disabled' }}>
        <option value="">كل الفئات</option>
        @foreach ($categories as $category)
        <option value="{{ $category->id }}" {{ $category->id == $selectedCategory ? 'selected' : '' }}>{{ $category->name }}</option>
        @endforeach
      </select>

      <input type="text" class="form-control col-md-2" name="customer_search" id="customer_search" onkeyup="filterCustomers()" placeholder="...البحث عن عميل" value="{{ request('customer_search') }}">
      <div id="suggestions" class="suggestions-box" style="display: none;"></div>
      <input type="hidden" name="customer_id" id="customer_id" value="{{ request('customer_id') }}">
      <button type="button" class="btn btn-primary btn-sm" onclick="selectAllCustomers()">كل العملاء</button>

      <div class="input-group col-md-3">
        <input type="number" class="form-control" id="bookingServiceId" placeholder="{{translate('Booking No')}}"
          name="bookingServiceId" id="bookingServiceId" value="{{ request('bookingServiceId') }}"
          aria-label="Recipient's username" aria-describedby="basic-addon2">
        <div class="input-group-append">
          <button class="btn btn-primary btn-sm" type="button" id="btnViewBookingNo" onclick="this.form.submit()">{{translate('Load')}}</button>
        </div>
      </div>
    </div>

    <div style="margin: 0; margin-left: 20px;" class="row justify-content-start flex-wrap mb-3 align-items-center">
      <input type="date" name="date" id="date" onchange="this.form.submit()" class="form-select" value="{{ request('date') ?? now()->toDateString() }}">
      <div class="float-right m-1" id="divPreNext">
        <i id="PrvDate" onclick="navigateDate(-1)" title="{{translate('Previous day')}}" class="iChangeDate fa fa-chevron-left float-left"></i>
        <i id="NextDate" onclick="navigateDate(1)" title="{{translate('Next day')}}" class="iChangeDate fa fa-chevron-right float-right"></i>
      </div>
    </div>
  </form>
  <div style="margin: 15px; display: flex; justify-content: flex-end">
    <button class="btn btn-success btn-sm" id="btnAddSchedule"><i class="fas fa-plus-circle"></i> {{translate('Add Schedule')}}</button>
  </div>
  <!-- Status Panel -->
  <div class="status-panel">
    @php
    $statusCounts = [
    \App\Enums\ServiceStatus::Pending => 0,
    \App\Enums\ServiceStatus::Processing => 0,
    \App\Enums\ServiceStatus::Approved => 0,
    \App\Enums\ServiceStatus::Cancel => 0,
    \App\Enums\ServiceStatus::Done => 0,
    ];

    foreach ($bookingService as $booking) {
    $statusCounts[$booking->status]++;
    }
    @endphp
    <div class="status-item status-total-booking">{{translate('Total Booking')}}: {{count($bookingService)}}</div>
    <div class="status-item status-pending">{{translate('Pending')}}: {{ $statusCounts[\App\Enums\ServiceStatus::Pending] }}</div>
    <div class="status-item status-processing">{{translate('Processing')}}: {{ $statusCounts[\App\Enums\ServiceStatus::Processing] }}</div>
    <div class="status-item status-approved">{{translate('Approved')}}: {{ $statusCounts[\App\Enums\ServiceStatus::Approved] }}</div>
    <div class="status-item status-cancel">{{translate('Cancel')}}: {{ $statusCounts[\App\Enums\ServiceStatus::Cancel] }}</div>
    <div class="status-item status-done">{{translate('Done')}}: {{ $statusCounts[\App\Enums\ServiceStatus::Done] }}</div>
  </div>
  <hr>
  <!-- Pagination Links for Services -->
  <div class="pagination-links" style="margin: 10px 0;">
    {{ $data->links('vendor.pagination.ajax') }}
  </div>
  <div class="table-responsive" style="margin-top: 10px;">
    <table class="calendar-table">
      <!-- Table Header -->
      <thead>
        <tr>
          <th class="hour-header">الساعة</th>
          @forelse ($data as $item)
          <th class="service-header">
            <div class="service-image">
              <img src="{{ $item->image }}" alt="{{ $item->title }}">
            </div>
            <p class="service-title">{{ $item->title }}</p>
          </th>
          @empty
          <th colspan="100%">No data available</th>
          @endforelse
        </tr>
      </thead>

      <!-- Table Body -->
      <tbody>
        @for ($hour = 0; $hour < 24; $hour++)
          <tr class="{{ $hour % 2 === 0 ? 'even-row' : 'odd-row' }}">
          <td class="hour-cell px-1">{{ str_pad(date('g:i A', strtotime("$hour:00")), 5, '0', STR_PAD_LEFT) }}</td>
          @foreach ($data as $item)
          <td class="service-cell">
            @foreach ($bookingService as $booking)
            @php
            $bookingHour = (int) date('H', strtotime($booking->start_time));
            $statusColors = [
            \App\Enums\ServiceStatus::Pending => '#f1892d',
            \App\Enums\ServiceStatus::Processing => '#07aba0',
            \App\Enums\ServiceStatus::Approved => '#0077c0',
            \App\Enums\ServiceStatus::Cancel => '#e74c3c',
            \App\Enums\ServiceStatus::Done => '#0eac51'
            ];
            $color = $statusColors[$booking->status] ?? 'black';
            @endphp
            @if ($booking->service == $item->title && $bookingHour == $hour)
            <div onclick="fetchBookingDetails('{{ $booking->id }}')"
              style="margin-bottom: 5px; padding: 10px; border-radius: 4px; color: white; font-size: 0.9em; text-align: center; background-color: {{$color}};">
              <strong>{{ $booking->customer }}</strong><br>
              {{ date('g:i A', strtotime($booking->start_time)) }} - {{ date('g:i A', strtotime($booking->end_time)) }}<br>
            </div>
            @endif
            @endforeach
          </td>
          @endforeach
          </tr>
          @endfor
      </tbody>

    </table>
  </div>
</div>

<!-- add schedule modal -->
<div class="modal fade" id="frmAddScheduleModal" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <form class="form-horizontal" id="inputFormBooking" novalidate="novalidate">

        <div class="modal-header">
          <h5 class="modal-title">
            <span class="fw-mediumbold">
              {{translate('Add/Edit Service')}}
            </span>
          </h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">

          <section>
              <div class="form-row flex-row-reverse">
                <div class="col-md-4 control-group">
                  <label for="zone_id" class="float-left">{{translate('Zone')}}</label>
                  <select required id="zone_id" name="zone_id" class="serviceInput form-control">
                    <option value="" disabled selected>{{translate('اختر الخدمة')}}</option>
                  </select>
                </div>
                <div class="col-md-4 control-group">
                  <label for="cmn_branch_id" class="float-left">{{translate('Branch')}}</label>
                  <select required id="cmn_branch_id" name="cmn_branch_id" class="serviceInput form-control">
                    <option value="" disabled selected>{{translate('اختر الخدمة')}}</option>
                  </select>
                </div>
                <div class="col-md-4 control-group">
                  <label for="sch_service_category_id" class="float-left">{{translate('Category')}}</label>
                  <select required id="sch_service_category_id" name="sch_service_category_id" class="serviceInput form-control">
                  </select>
                </div>
                <div class="col-md-4 control-group">
                  <label for="sch_service_id" class="float-left">{{translate('Service')}}</label>
                  <select required id="sch_service_id" name="sch_service_id" class="serviceInput form-control">
                    <option value="" disabled selected>{{translate('اختر الخدمة')}}</option>
                  </select>
                </div>
                <div class="col-md-4 control-group">
                  <label for="sch_employee_id" class="float-left">{{translate('Staff')}}</label>
                  <select required id="sch_employee_id" name="sch_employee_id" class="serviceInput form-control">
                    <option value="" disabled selected>{{translate('اختر الحجز')}}</option>
                  </select>
                </div>
              </div>
            <div class="form-row mt-2">
              <div class="col-md-auto col-lg-auto col-sm-auto" id="divServiceCalendar">
                <div class="row">
                  <div class="col-md-12">
                    <label for="serviceDate" class="float-right">{{translate('Service Date')}}</label>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-12 control-group">
                    <input id="serviceDate" required name="service_date" class="form-control input-sm" type="text" readonly />
                    <div id="divServiceDate" style="float: left;"></div>
                  </div>
                </div>

              </div>
              <div class="col">
                <div id="divTopDays">
                  <div class="row">
                    <div class="col-md-12">
                      <div class="float-left" id="divDaysName"></div>
                      <div class="float-right" id="divPreNext">
                        <i id="iPrvDate" title="{{translate('Previous day')}}" class="iChangeDate fa fa-chevron-left float-left"></i>
                        <i id="iNextDate" title="{{translate('Next day')}}" class="iChangeDate fa fa-chevron-right float-right"></i>
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

            <div class="form-row">
              <div class="col divSelectedService">
                <i class="fa fa-calendar float-left pl-2 mt-1 mr-1" aria-hidden="true"></i>
                <i id="iSelectedServiceText" class=""></i>
              </div>

              <div class="col-md-auto col-lg-auto col-sm-auto float-end">
                <button type="button" class="btn btn-success float-end" id="add-service-btn"><i class="fas fa-plus-circle"></i> {{translate('Add more service')}}</button>
              </div>

            </div>

            <div class="form-row d-none" id="div-service-summary">
              <div class="col-md-12">
                <table id="tbl-service-cart" class="table table-bordered fs-13 text-start">
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

              <div class="col-md-12">
                <div class="float-right mb-3 mt-2"><b>{{translate('Total Amount:')}} <span id="service-total-amount"></span> </b> </div>
              </div>
              <div class="col-md-12">
                <div class="float-right"><b>{{translate('Discount Amount:')}} <span id="service-discount-amount">0</span> </b> </div>
              </div>

              <div class="col-md-12 control-group">
                <label for="coupon_code" class="float-left">{{translate('Apply Coupon Code')}}</label>
                <div class="input-group">
                  <input id="coupon_code" name="coupon_code" class="form-control" data-live-search="true" />
                  <div class="input-group-append">
                    <button id="btn-apply-coupon" class="btn btn-success btn-sm" type="button"> {{translate('Apply Coupon')}}</button>
                  </div>
                </div>
              </div>
              <div class="col-md-12">
                <div class="float-right mt-4"><b>{{translate('Payable Amount:')}} <span id="service-payable-amount"></span> </b> </div>
              </div>


            </div>

            <div class="form-row">
              <div class="col-md-12 mt-3 control-group">
                <label for="cmn_customer_id" class="float-left">{{translate('Customer')}} <b class="color-red"> *</b> </label>
                <div class="input-group">
                  <select required id="cmn_customer_id" name="cmn_customer_id" class="form-control" data-live-search="true"></select>
                  <div class="input-group-append">
                    <button id="btnAddNewCustomer" class="btn btn-primary btn-sm" type="button"><i class="fas fa-plus-circle"></i> {{translate('Add Customer')}}</button>
                  </div>
                </div>
              </div>
              <div class="col-md-12 mt-3">
                <div class="row">
                  <div class="col-md-7 control-group">
                    <label for="monthly" class="float-left">تكرار الحجز <b class="color-red"> *</b></label>
                    <select required id="monthly" name="monthly" class="form-control">
                      <option value="once">مره واحده</option>
                      <option value="monthly">شهريا</option>
{{--                      <option value="monthly_skip">{{translate('monthly & skip')}}</option>--}}
                    </select>
                  </div>
                  <div class="col-md-5 control-group">
                    <label for="status" class="float-left">{{translate('Application Status')}}</label>
                    <select required id="status" name="status" class="form-control">
                      <option value="2">{{translate('Approved')}}</option>
                      <option value="0">{{translate('Pending')}}</option>
                      <option value="1">{{translate('Processing')}}</option>
                      <option value="3">{{translate('Cancel')}}</option>
                      <option value="4">{{translate('Done')}}</option>
                    </select>
                  </div>
                </div>
              </div>
              <div class="col-md-12 mt-3">
                <div class="row">
                  <div class="col-md-7 control-group">
                    <label for="cmn_payment_type_id" class="float-left">{{translate('Payment By')}}<b class="color-red"> *</b></label>
                    <select required id="cmn_payment_type_id" name="cmn_payment_type_id" class="form-control"></select>
                  </div>
                  <div class="col-md-5 control-group">
                    <label for="paid_amount" class="float-left">{{translate('Paid Amount')}}</label>
                    <input required type="number" id="paid_amount" name="paid_amount" class="form-control" min="0" onkeyup=enforceMinMax(this) />
                    <div id="divPaymentStatus" class="d-none">{{translate('Paid/Unpaid')}}</div>
                  </div>
                </div>
              </div>
              
              <div class="col-md-12 mt-3 control-group">
                <label for="remarks" class="float-left">{{translate('Remarks')}}</label>
                <textarea id="remarks" name="remarks" class="form-control" rows="2"></textarea>
              </div>
              <!-- <div class="col-md-12 control-group">
                <div class="form-group control-group form-inline">
                  <label class="switch">
                    <input id=email_notify name="email_notify" type="checkbox" value="1" class="rm-slider">
                    <span class="slider round"></span>
                  </label>
                  <label class="pt-1 ml-1"> {{translate('Send booking notification by email')}}</label>
                  <span class="help-block"></span>
                </div>
              </div> -->
            </div>
          </section>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">إغلاق</button>
          <button type="submit" class="btn btn-success btn-sm">حفظ</button>

        </div>
      </form>

    </div>
  </div>
</div>
<!-- end add schedule modal -->

<!-- start customer modal -->
<div class="modal fade" id="modalAddCustomer" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <form class="form-horizontal" id="inputFormCustomer" novalidate="novalidate">

        <div class="modal-header">
          <h5 class="modal-title">
            <span class="fw-mediumbold">
              {{translate('Add Customer')}}
            </span>
          </h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="row">
            <div class="col-md-12">
              <div class="form-group control-group form-inline controls">
                <label>اسم المستخدم *</label>
                <input type="text" id="full_name" name="full_name" placeholder="الاسم بالكامل" required data-validation-required-message="Customer name is required" class="form-control input-full" />
                <span class="help-block"></span>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col-md-7">
              <div class="form-group control-group form-inline controls">
                <label class="col-md-12 p-0">رقم الهاتف *</label>
                <input type="tel" id="phone_no" maxlength="20" name="phone_no" placeholder="ادخل رقم هاتف العميل" required data-validation-required-message="Phone number is required" class="form-control input-full w-100" />
                <span class="help-block"></span>
              </div>
            </div>
          </div>

          <div class="form-group control-group form-inline controls">
            <label>ملاحظات</label>
            <input type="text" id="remarks" name="remarks" class="form-control input-full" />
            <span class="help-block"></span>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">Close</button>
          <button type="submit" class="btn btn-success btn-sm">Save Change</button>

        </div>
      </form>

    </div>
  </div>
</div>
<!-- end customer modal -->
@endsection