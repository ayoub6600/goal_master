
(function ($) {
    "use strict";
    $(document).on('click', ".payment-choose-div", function () {
        $(this).find('input').prop('checked', true);
        $(".payment-choose-div").removeClass('payment-choose');
        $(this).addClass('payment-choose');
    });

    $("#btnNext").on("click", function () {
        Manager.PayDueBookingAmount();
    });

    $(document).on('click', ".payment-chose-div", function () {
        $(this).find('input').prop('checked', true);
        $(".payment-chose-div").removeClass('payment-chose');
        $(this).addClass('payment-chose');
    });
    
    var Manager = {
        PayDueBookingAmount: function () {
            JsManager.StartProcessBar();
            var jsonParam = { bookingId: Utility.GetUrlParamValue('bookingId'), paymentType: $('input[name="payment_type"]:checked').val() };
            var serviceUrl = 'site-make-online-due-payment';
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    if (jsonData.paymentType == "paypal") {
                        if (jsonData.data.returnUrl.status = 201) {
                            window.location.href = jsonData.data.returnUrl.data.links[1].href;
                        } else {
                            //order will be cancel by redirect
                            SiteManager.CancelBooking(jsonData.data.returnUrl.purchase_units[0].reference_id)
                        }
                    }
                    else if (jsonData.paymentType == "stripe") {
                        window.location.href = jsonData.data.returnUrl.redirectUrl;
                    }
                    else if (jsonData.paymentType == "userBalance") {
                        window.location.href = jsonData.data.returnUrl.redirectUrl;
                    }
                    JsManager.EndProcessBar();
                } else {
                    Message.Error("Failed to payment");
                    JsManager.EndProcessBar();
                }
                JsManager.EndProcessBar();
            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }
        },
    };


})(jQuery);

