(function ($) {
    "use strict";
    $(document).ready(function () {
        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            var formData = new FormData(document.querySelector('#inputForm'));
            AppearanceManager.Save(formData);

        });

    });


    var AppearanceManager = {
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "website-save-or-update-google-map";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

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