(function ($) {
    "use strict";
    $(document).ready(function () {

        Coloris({
            el: '.coloris',
            swatches: [
                '#007bff',
                '#0b66c8',
                '#499df6',
                '#264653',
                '#2a9d8f',
                '#ff6626',
                '#fd9637',
                '#e76f51',
                '#d62828',
                '#023e8a',
                '#0077b6',
                '#0096c7'
            ]
        });

        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            var formData = new FormData(document.querySelector('#inputForm'));
            AppearanceManager.Save(formData);

        });

    });

    //icon preview
    $(document).on('change', '#icon', function () {
        var output = document.getElementById('icon-view');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src)
        }
    });
    //logo preview
    $(document).on('change', '#logo', function () {
        var output = document.getElementById('logo-view');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src)
        }
    });
    //background image preview
    $(document).on('change', '#background_image', function () {
        var output = document.getElementById('background-image-view');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src)
        }
    });

    //login background image preview
    $(document).on('change', '#login_background_image', function () {
        var output = document.getElementById('login-background-image-view');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src)
        }
    });


    var AppearanceManager = {
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "website-appearance-save-or-update";
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