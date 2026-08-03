(function ($) {
    "use strict";
    $(document).ready(function () {
        $('.start_time').datetimepicker({
            datepicker: false,
            format: 'H:i',
            step: 5,
            onShow: function (ct, el) {
                this.setOptions({
                    maxTime: $(el).parent().parent().find('.end_time').val() ? $(el).parent().parent('tr').find('.end_time').val() : false
                })
            }
        });
        $('.end_time').datetimepicker({
            datepicker: false,
            format: 'H:i',
            step: 5,
            onShow: function (ct, el) {
                this.setOptions({
                    minTime: $(el).parent().parent().find('.start_time').val() ? $(el).parent().parent('tr').find('.start_time').val() : false
                })
            }
        });

        //load branch name dropdown
        BusinessHourManager.LoadBranchDropDown();
        BusinessHourManager.PopulateData($("#cmn_branch_id").val());

        $("#cmn_branch_id").on("change", function () {
            BusinessHourManager.PopulateData($(this).val());
        });

        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            BusinessHourManager.Save(form);
        });
    });


    var BusinessHourManager = {

        PopulateData: function (branchId) {
            JsManager.StartProcessBar();
            var jsonParam = { branchId: branchId };
            var serviceUrl = 'get-branch-wise-business-hours';
            JsManager.SendJson("GET", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                $('#inputForm').find('.id').val('');
                $('#inputForm').find('.start_time').val('');
                $('#inputForm').find('.end_time').val('');
                $('#inputForm').find('.is_off_day').prop("checked", false);
                if (jsonData.status == "1") {
                    $.each($("#tblBusinessHour tr"), function (tri, trv) {
                        if (tri > 0) {
                            $.each(jsonData.data, function (di, dv) {
                                if ($(trv).find('.day').val() == dv.day) {
                                    $(trv).find(".id").val(dv.id);
                                    $(trv).find(".start_time").val(dv.start_time);
                                    $(trv).find(".end_time").val(dv.end_time);
                                    if (dv.is_off_day == 1) {
                                        $(trv).find(".is_off_day").prop("checked", true);
                                    } else {
                                        $(trv).find(".is_off_day").prop("checked", false);
                                    }
                                }
                            });
                        }
                    });

                } else {
                    Message.Error("Failed to get");
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
                var jsonParam = form.serialize();
                var serviceUrl = 'business-hour-store';
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

        LoadBranchDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-branch-dropdown";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#cmn_branch_id", jsonData.data);
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        }


    }
})(jQuery);


