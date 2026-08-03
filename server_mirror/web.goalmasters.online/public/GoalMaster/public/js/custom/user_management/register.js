(function ($) {
    "use strict";
    $(document).ready(function () {

        $("#chkSignUpWith").change(function () {
            if ($(this).prop('checked')) {
                // $("#divEmail").hide();
                $("#divPhone").show();

                // $("#email").attr('required', false);
                $("#phone").attr('required', true);
            } else {
                // $("#divEmail").show();
                $("#divPhone").hide();

                // $("#email").attr('required', true);
                $("#phone").attr('required', false);
            }
        });

    });
})(jQuery);