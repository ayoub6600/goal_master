(function ($) {
    "use strict";
    $(document).ready(function () {

        //save or update
        JsManager.JqBootstrapValidation('#passwordChangeForm', (form, event) => {
            event.preventDefault();
            ChangePasswordManager.UpdatePassword(form);
        });

    });


    var ChangePasswordManager = {

        UpdatePassword: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "change-user-password";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("Password change successfully.");
                        form.trigger('reset');
                    } else if (jsonData.status == "-1") {
                        Message.Error("Current password is invalid.");
                    } else {
                        Message.Error("Failed to change password.");
                    }
                    JsManager.EndProcessBar();

                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        }

    };
})(jQuery);
