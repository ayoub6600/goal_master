(function ($) {    
    "use strict";
    
    $(document).ready(function () {
        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            // EmailConfiguration.Save(form);

        });
    });

    // var EmailConfiguration = {
    //     Save: function (form) {
    //         if (Message.Prompt()) {
    //             JsManager.StartProcessBar();
    //             var jsonParam = form.serialize();
    //             var serviceUrl = "save-email-configuration";
    //             JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

    //             function onSuccess(jsonData) {
    //                 if (jsonData.status == "1") {
    //                     Message.Success("save");
    //                 } else {
    //                     Message.Error("save");
    //                 }
    //                 JsManager.EndProcessBar();
    //             }

    //             function onFailed(xhr, status, err) {
    //                 JsManager.EndProcessBar();
    //                 Message.Exception(xhr);
    //             }
    //         }
    //     },
    // };
})(jQuery);