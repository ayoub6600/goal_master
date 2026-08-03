(function ($) {
    "use strict";
    $(document).ready(function () {
        OrderPaymentManager.PaymentType();
        $("#btnMakePayment").on('click', function () {
            OrderPaymentManager.MakePayment();
        });
    });

    $(document).on('click', ".payment-chose-div", function () {
        $(this).find('input').prop('checked', true);
        $(".payment-chose-div").removeClass('payment-chose');
        $(this).addClass('payment-chose');
    });

    var OrderPaymentManager = {
        MakePayment: function () {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { payment_type: $("input[name='payment_type']:checked").val() };
                var serviceUrl = "site-order-process-to-payment";
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
            }
        },
        PaymentType: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-payment-type";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {

                if (jsonData.status == 1) {
                    $.each(jsonData.data, function (i, v) {
                        let typeIcon = '<img src="img/payment-cash.svg" />';
                        let checkStatus = "";
                        let activePayment = '';
                        if (v.type == 2) {
                            typeIcon = '<img src="img/payment-paypal.svg" />';
                            checkStatus = 'checked';
                            activePayment = 'payment-chose';
                        } else if (v.type == 3) {
                            typeIcon = '<img src="img/payment-stripe.svg" />';
                        }
                        else if (v.type == 4) {
                            typeIcon = '<img src="img/payment-user-balance.svg" />';
                        }

                        $("#divPaymentMethod").append('<div class="payment-chose-div float-start ' + activePayment + '">' +
                            '<input  ' + checkStatus + ' type="radio" name="payment_type" id="payment_type" value="' + v.id + '" class="float-start payment-radio d-none" />' +
                            '<div class="float-start color-black p-2">' + typeIcon + '</div>' +
                            '</div>');

                    });
                }
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        }
    };
})(jQuery);