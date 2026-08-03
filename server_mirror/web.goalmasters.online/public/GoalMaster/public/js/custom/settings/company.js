(function ($) {
    "use strict";

    var _id = null;
    $(document).ready(function () {

        Manager.GetData();
        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            Manager.Save(form, _id);
        });

    });


    var Manager = {

        GetData: function (form, id) {
            JsManager.StartProcessBar();
            var jsonParam = {};
            var serviceUrl = "get-company";
            JsManager.SendJson("GET", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1" && jsonData.data != null) {
                    var data = jsonData.data;
                    _id = data.id;
                    $('#name').val(data.name);
                    $('#address').val(data.address);
                    $('#phone').val(data.phone);
                    $('#mobile').val(data.mobile);
                    $('#email').val(data.email);
                    $('#web_address').val(data.web_address);
                }
                JsManager.EndProcessBar();

            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }

        },
        Save: function (form, id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&id=" + id;
                var serviceUrl = id != null ? "company-update" : "company-store";
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
        }
    }
})(jQuery);