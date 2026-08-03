(function ($) {
    "use strict";
    var initTelephone;
    $(document).ready(function () {
        ClientManager.GetUserInfo();
        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault(); 
            var formData = new FormData(document.querySelector('#inputForm'));
            formData.append('phone_no', $('#phone_no').val());
            ClientManager.Save(formData);

        });

        initTelephone = window.intlTelInput(document.querySelector("#phone_no"), {
            allowDropdown: true,
            autoHideDialCode: false,
            dropdownContainer: document.body,
            excludeCountries: [],
            formatOnDisplay: false,
            geoIpLookup: function (callback) {
                $.get("https://ipinfo.io?token=e9e7414da3c91f", function () { }, "json").always(function (resp) {
                    var countryCode = (resp && resp.country) ? resp.country : "";
                    callback(countryCode);
                });
            },
            initialCountry: "auto",
            nationalMode: true,
            placeholderNumberType: "MOBILE",
            separateDialCode: true,
            utilsScript: "js/lib/tel-input/js/utils.js",
        });

    });


    //logo preview
    $(document).on('change', '#user_photo', function () {
        var output = document.getElementById('user_photo_view');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src)
        }
    });

    var ClientManager = {
        GetUserInfo: function (form) {
            JsManager.StartProcessBar();
            var jsonParam = form;
            var serviceUrl = "get-user-basic-profile";
            JsManager.SendJsonWithFile("GET", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    let dataUser = jsonData.data['user'];
                    let dataCustomer = jsonData.data['customer'];
                    $("#user_photo_view").attr('src', JsManager.BaseUrl() + "/" + dataUser.photo);
                    $("#name").val(dataUser.name);
                    $("#username").val(dataUser.username);
                    // $("#email").val(dataUser.email);

                    if (dataCustomer != null) {
                        initTelephone.setNumber(dataCustomer.phone_no);
                        $("#dob").val(dataCustomer.dob);
                        $("#street_address").val(dataCustomer.street_address);
                        $("#street_number").val(dataCustomer.street_number);
                        $("#state").val(dataCustomer.state);
                        $("#city").val(dataCustomer.city);
                        $("#postal_code").val(dataCustomer.postal_code);
                        $("#country").val(dataCustomer.country);
                    }
                }
                JsManager.EndProcessBar();
            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }

        },
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "save-or-update-client-profile";
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