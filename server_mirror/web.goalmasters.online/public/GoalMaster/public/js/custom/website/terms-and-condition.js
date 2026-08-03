(function ($) {
    "use strict";

    var editor;
    $(document).ready(function () {
        editor = new toastui.Editor({
            el: document.querySelector('#editor'),
            height: '500px',
            //initialValue: content,
            initialEditType: 'wysiwyg'
        });


        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            var formData = new FormData(document.querySelector('#inputForm'));
            formData.append("details", editor.getHtml());
            Manager.Save(formData);

        });

    });

    var Manager = {
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "website-save-or-update-terms-and-condition";
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
        }
    };
})(jQuery);