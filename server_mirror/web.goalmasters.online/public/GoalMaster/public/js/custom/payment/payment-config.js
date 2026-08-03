(function ($) {
    "use strict";
    $(document).ready(function () {

        JsManager.JqBootstrapValidation('#inputFormCurrency', (form, event) => {
            event.preventDefault();
            Manager.SaveCurrency(form);
        });
        JsManager.JqBootstrapValidation('#inputFormLocalPayment', (form, event) => {
            event.preventDefault();
            Manager.EnableLocalPayment(form);
        });
        JsManager.JqBootstrapValidation('#inputFormPaypalPayment', (form, event) => {
            event.preventDefault();
            Manager.EnablePaypalPayment(form);
        });
        JsManager.JqBootstrapValidation('#inputFormPaypalConfig', (form, event) => {
            event.preventDefault();
            Manager.SaveOrUpdatePaypalConfig(form);
        });
        JsManager.JqBootstrapValidation('#inputFormStripeConfig', (form, event) => {
            event.preventDefault();
            Manager.SaveOrUpdateStripeConfig(form);
        });
        $("#charge_type").val($("#storedChargeType").val());
        $("#currency").val($("#storedCurrencyValue").val());

        $("#enableStripePayment").on("change",function(){
            Manager.EnableStripePayment();
        });

    });

    var Manager = {
        SaveCurrency: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + '&name=' + $('option:selected', "#currency").data('symbol');
                var serviceUrl = "save-or-update-currency";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                    } else {
                        Message.Error("save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },
        EnableLocalPayment: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "enable-or-disable-local-payment";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                    } else {
                        Message.Error("save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },
        EnablePaypalPayment: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "enable-or-disable-paypal-payment";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                    } else {
                        Message.Error("save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },

      

        SaveOrUpdatePaypalConfig: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "save-or-update-paypal-config";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                    } else {
                        Message.Error("save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },

        // stripe payment geteway config
        EnableStripePayment: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = {enableStripePayment:$("#enableStripePayment").prop('checked')};
                var serviceUrl = "enable-or-disable-stripe-payment";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                    } else {
                        Message.Error("save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },

        SaveOrUpdateStripeConfig: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "save-or-update-stript-config";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                    } else {
                        Message.Error("save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },
    };
})(jQuery);