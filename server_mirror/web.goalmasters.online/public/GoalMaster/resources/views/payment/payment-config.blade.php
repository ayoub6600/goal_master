@extends('layouts.app')
@section('content')
<div class="page-inner">
  <div class="row">

    <!-- start currency setup -->
    <div class="col-md-4">
      <div class="card">
        <div class="card-header">
          <h2><i class="fas fa-cogs"></i> {{translate('Currency Setup')}}</h2>
        </div>
        <form class="form-horizontal" id="inputFormCurrency" novalidate="novalidate">
          <div class="card-body">
            <div class="form-group">
              <select name="currency" id="currency" class=" form-control input-full">
                <option value="USD" data-symbol="$">USD ($)</option>
                <option value="AED" data-symbol="AED">AED (AED)</option>
                <option value="AMD" data-symbol="դր.">AMD (դր.)</option>
                <option value="ANG" data-symbol="ƒ">ANG (ƒ)</option>
                <option value="AOA" data-symbol="Kz">AOA (Kz)</option>
                <option value="ARS" data-symbol="$">ARS ($)</option>
                <option value="AUD" data-symbol="A$">AUD (A$)</option>
                <option value="BAM" data-symbol="KM">BAM (KM)</option>
                <option value="BDT" data-symbol="৳">BDT (৳)</option>
                <option value="BGN" data-symbol="лв.">BGN (лв.)</option>
                <option value="BHD" data-symbol="BHD">BHD (BHD)</option>
                <option value="BRL" data-symbol="R$">BRL (R$)</option>
                <option value="BWP" data-symbol="P">BWP (P)</option>
                <option value="CAD" data-symbol="C$">CAD (C$)</option>
                <option value="CHF" data-symbol="CHF">CHF (CHF)</option>
                <option value="CLP" data-symbol="$">CLP ($)</option>
                <option value="COP" data-symbol="$">COP ($)</option>
                <option value="CRC" data-symbol="₡">CRC (₡)</option>
                <option value="CUC" data-symbol="CUC$">CUC (CUC$)</option>
                <option value="CZK" data-symbol="Kč">CZK (Kč)</option>
                <option value="DKK" data-symbol="kr">DKK (kr)</option>
                <option value="DOP" data-symbol="RD$">DOP (RD$)</option>
                <option value="DZD" data-symbol="DA">DZD (DA)</option>
                <option value="EGP" data-symbol="EGP">EGP (EGP)</option>
                <option value="EUR" data-symbol="€">EUR (€)</option>
                <option value="FJD" data-symbol="F$">FJD (F$)</option>
                <option value="GBP" data-symbol="£">GBP (£)</option>
                <option value="GEL" data-symbol="₾">GEL (₾)</option>
                <option value="GHS" data-symbol="GH¢">GHS (GH¢)</option>
                <option value="GTQ" data-symbol="Q">GTQ (Q)</option>
                <option value="HKD" data-symbol="HK$">HKD (HK$)</option>
                <option value="HRK" data-symbol="kn">HRK (kn)</option>
                <option value="HUF" data-symbol="Ft">HUF (Ft)</option>
                <option value="IDR" data-symbol="Rp">IDR (Rp)</option>
                <option value="ILS" data-symbol="₪">ILS (₪)</option>
                <option value="INR" data-symbol="₹">INR (₹)</option>
                <option value="IRR" data-symbol="﷼">IRR (﷼)</option>
                <option value="ISK" data-symbol="kr">ISK (kr)</option>
                <option value="JMD" data-symbol="$">JMD ($)</option>
                <option value="JOD" data-symbol="JD">JOD (JD)</option>
                <option value="JPY" data-symbol="¥">JPY (¥)</option>
                <option value="KES" data-symbol="KSh">KES (KSh)</option>
                <option value="KRW" data-symbol="₩">KRW (₩)</option>
                <option value="KWD" data-symbol="KD">KWD (KD)</option>
                <option value="KZT" data-symbol="тг.">KZT (тг.)</option>
                <option value="LAK" data-symbol="₭">LAK (₭)</option>
                <option value="LBP" data-symbol="ل.ل.">LBP (ل.ل.)</option>
                <option value="LKR" data-symbol="Rs.">LKR (Rs.)</option>
                <option value="MAD" data-symbol="Dh">MAD (Dh)</option>
                <option value="MDL" data-symbol="L">MDL (L)</option>
                <option value="MKD" data-symbol="ден.">MKD (ден.)</option>
                <option value="MUR" data-symbol="Rs">MUR (Rs)</option>
                <option value="MXN" data-symbol="$">MXN ($)</option>
                <option value="MYR" data-symbol="RM">MYR (RM)</option>
                <option value="MZN" data-symbol="MT">MZN (MT)</option>
                <option value="NAD" data-symbol="N$">NAD (N$)</option>
                <option value="NGN" data-symbol="₦">NGN (₦)</option>
                <option value="NOK" data-symbol="Kr">NOK (Kr)</option>
                <option value="NZD" data-symbol="$">NZD ($)</option>
                <option value="OMR" data-symbol="OMR">OMR (OMR)</option>
                <option value="PEN" data-symbol="S/.">PEN (S/.)</option>
                <option value="PHP" data-symbol="₱">PHP (₱)</option>
                <option value="PKR" data-symbol="Rs.">PKR (Rs.)</option>
                <option value="PLN" data-symbol="zł">PLN (zł)</option>
                <option value="PYG" data-symbol="₲">PYG (₲)</option>
                <option value="QAR" data-symbol="QAR">QAR (QAR)</option>
                <option value="RMB" data-symbol="¥">RMB (¥)</option>
                <option value="RON" data-symbol="lei">RON (lei)</option>
                <option value="RSD" data-symbol="din.">RSD (din.)</option>
                <option value="RUB" data-symbol="руб.">RUB (руб.)</option>
                <option value="SAR" data-symbol="SAR">SAR (SAR)</option>
                <option value="SCR" data-symbol="₨">SCR (₨)</option>
                <option value="SEK" data-symbol="kr">SEK (kr)</option>
                <option value="SGD" data-symbol="$">SGD ($)</option>
                <option value="THB" data-symbol="฿">THB (฿)</option>
                <option value="TRY" data-symbol="TL">TRY (TL)</option>
                <option value="TTD" data-symbol="$">TTD ($)</option>
                <option value="TWD" data-symbol="NT$">TWD (NT$)</option>
                <option value="TZS" data-symbol="TSh">TZS (TSh)</option>
                <option value="UAH" data-symbol="₴">UAH (₴)</option>
                <option value="UGX" data-symbol="UGX">UGX (UGX)</option>
                <option value="VND" data-symbol="VNĐ">VND (VNĐ)</option>
                <option value="XAF" data-symbol="FCFA">XAF (FCFA)</option>
                <option value="XOF" data-symbol="CFA">XOF (CFA)</option>
                <option value="XPF" data-symbol="FCFP">XPF (FCFP)</option>
                <option value="ZAR" data-symbol="R">ZAR (R)</option>
                <option value="ZMW" data-symbol="K">ZMW (K)</option>
              </select>
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>
          </div>
        </form>
      </div>
    </div>
    <!-- end currency setup -->

    <!-- start enable local payment -->
    <div class="col-md-4">
      <div class="card">
        <div class="card-header">
          <h2><i class="far fa-money-bill-alt"></i> {{translate('Local Payment')}}</h2>
        </div>
        <form class="form-horizontal" id="inputFormLocalPayment" novalidate="novalidate">
          <div class="card-body">
            <div class="row">
              <div class="col-md-12 controls">
                <div class="form-group control-group form-inline">
                  <label class="switch">
                    <input id="enableLocalPayment" {{$paymentConfig['local_payment_status']==1?"checked":""}} name="enableLocalPayment" type="checkbox" value="1" class="rm-slider" />
                    <span class="slider round"></span>
                  </label>
                  <label class="pt-1 ml-1">
                    <h5>{{translate('Local Payment')}}</h5>
                  </label>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>
          </div>
        </form>
      </div>
    </div>
    <!-- end enable local payment -->

    <!-- start enable paypal payment -->
    <div class="col-md-4">
      <div class="card">
        <div class="card-header">
          <h2><i class="fab fa-paypal"></i> {{translate('Paypal Payment')}}</h2>
        </div>
        <form class="form-horizontal" id="inputFormPaypalPayment" novalidate="novalidate">
          <div class="card-body">
            <div class="row">
              <div class="col-md-12 controls">
                <div class="form-group control-group form-inline">
                  <label class="switch">
                    <input id="enablePaypalPayment" {{$paymentConfig['paypal_payment_status']==1?"checked":""}} name="enablePaypalPayment" type="checkbox" value="1" class="rm-slider" />
                    <span class="slider round"></span>
                  </label>
                  <label class="pt-1 ml-1">
                    <h5>{{translate('Paypal Payment')}}</h5>
                  </label>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>
          </div>
        </form>
      </div>
    </div>
    <!-- end enable paypal payment -->


  </div>





  <div class="row">

    <!-- start paypal setup -->
    <div class="col-md-6">
      <div class="card">
        <div class="card-header">
          <h2><i class="fab fa-paypal"></i> {{translate('Paypal Config')}}</h2>
        </div>
        <form class="form-horizontal" id="inputFormPaypalConfig" novalidate="novalidate">
          <div class="card-body">

            <div class="row">
              <div class="col-md-12 controls">
                <div class="form-group control-group form-inline">
                  <label> {{translate('Client ID')}}
                    <span class="required-label">*</span>
                  </label>
                  <input type="text" value="{{$paypalConfig['client_id']}}" id="client_id" name="client_id" placeholder="{{translate('Client ID')}}" required class="form-control input-full" data-validation-required-message="Paypal Client ID is required" />
                  <span class="help-block"></span>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-md-12 controls">
                <div class="form-group control-group form-inline">
                  <label> {{translate('Client Secret')}}
                    <span class="required-label">*</span>
                  </label>
                  <input type="text" value="{{$paypalConfig['client_secret']}}" id="client_secret" name="client_secret" placeholder="{{translate('Client Secret')}}" required class="form-control input-full" data-validation-required-message="Paypal Client Secret is required" />
                  <span class="help-block"></span>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-md-6 controls">
                <div class="form-group control-group form-inline">
                  <label> {{translate('Charge Type')}}
                  </label>
                  <select class="form-control input-full" id="charge_type" name="charge_type">
                  <option {{$paypalConfig['charge_type']==1?"selected ":""}} value="1">Addition</option>
                    <option {{$paypalConfig['charge_type']==2?"selected ":""}} value="2">Deduction</option>
                  </select>
                  <span class="help-block"></span>
                </div>
              </div>
              <div class="col-md-6 controls">
                <div class="form-group control-group form-inline">
                  <label> {{translate('Charge Percentage')}}
                  </label>
                  <input value="{{$paypalConfig['charge_percentage']}}" class="form-control input-full" id="charge_percentage" placeholder="%" name="charge_percentage" />
                  <span class="help-block"></span>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-md-12 controls">
                <div class="form-group control-group form-inline">
                  <label class="switch">
                    <input id="sandbox" name="sandbox" type="checkbox" value="1" {{$paypalConfig['sandbox']==1?"checked":""}} class="rm-slider" />
                    <span class="slider round"></span>
                  </label>
                  <label class="pt-1 ml-1">
                    <h5>{{translate('Enable Sandbox')}}</h5>
                  </label>
                </div>
              </div>
            </div>

          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>
          </div>
        </form>
      </div>
    </div>
    <!-- end paypal setup -->

    <!--start Stripe payment-->
    <div class="col-md-6">
      <div class="card">
        <div class="card-header">
          <h2><i class="fab fa-cc-stripe"></i> {{translate('Stripe Config')}}</h2>
        </div>
        <form class="form-horizontal" id="inputFormStripeConfig" novalidate="novalidate">
          <div class="card-body">

            <div class="form-group control-group form-inline">
              <label class="switch">
                <input id="enableStripePayment" {{$paymentConfig['stripe_payment_status']==1?"checked":""}} name="enableStripePayment" type="checkbox" value="1" class="rm-slider" />
                <span class="slider round"></span>
              </label>
              <label class="pt-1 ml-1">
                <h5>{{translate('Enable Stripe Payment')}}</h5>
              </label>
            </div>

            <div class="row">
              <div class="col-md-12 controls">
                <div class="form-group control-group form-inline">
                  <label> {{translate('API Key')}}
                    <span class="required-label">*</span>
                  </label>
                  <input type="text" value="{{$stripeConfig!==null?$stripeConfig['api_key']:''}}" id="api_key" name="api_key" placeholder="{{translate('API Key')}}" required class="form-control input-full" data-validation-required-message="Stripe API Key is required" />
                  <span class="help-block"></span>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-md-12 controls">
                <div class="form-group control-group form-inline">
                  <label> {{translate('API Secret')}}
                    <span class="required-label">*</span>
                  </label>
                  <input type="text" value="{{$stripeConfig!==null?$stripeConfig['api_secret']:''}}" id="api_secret" name="api_secret" placeholder="{{translate('API Secret')}}" required class="form-control input-full" data-validation-required-message="API Secret is required" />
                  <span class="help-block"></span>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-md-6 controls">
                <div class="form-group control-group form-inline">
                  <label> {{translate('Charge Type')}}
                  </label>
                  <select class="form-control input-full" id="charge_type" name="charge_type">
                    <option {{$stripeConfig!=null?($stripeConfig['charge_type']==1?"selected ":""):''}} value="1">Addition</option>
                    <option {{$stripeConfig!=null?($stripeConfig['charge_type']==2?"selected ":""):''}} value="2">Deduction</option>
                  </select>
                  <span class="help-block"></span>
                </div>
              </div>
              <div class="col-md-6 controls">
                <div class="form-group control-group form-inline">
                  <label> {{translate('Charge Percentage')}}
                  </label>
                  <input value="{{$stripeConfig!=null?$stripeConfig['charge_percentage']:''}}" class="form-control input-full" id="charge_percentage" placeholder="%" name="charge_percentage" />
                  <span class="help-block"></span>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-success btn-sm">{{translate('Save Change')}}</button>
          </div>
        </form>
      </div>
    </div>
    <!-- end stripe payment system -->


  </div>



  <input type="hidden" id="storedCurrencyValue" value="{{$paymentConfig['currency']}}" />
  <input type="hidden" id="storedChargeType" value="{{$paypalConfig->charge_type}}" />
</div>
@push("adminScripts")
<script src="{{dsAsset('js/custom/payment/payment-config.js')}}"></script>
@endpush
@endsection