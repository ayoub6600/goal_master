
(function ($) {
    "use strict";
    var scheduleTable;
    var scheduleTempData = null;
    var scheduleClickedTempData = null;
    var initTelephone;
    var currentEmpList = [];
    let subtotal = 0;
    let currency = '';
    var bookingList = [];

    var widthTimeTypes = [5, 10, 15, 30];
    $(document).ready(function () {
        ResourceTimeline.LoadBranchDropDown();
        // ResourceTimeline.LoadZoneDropDown();

        $('#reload_timeline').on("click", function () {
            selectedType = $('#Hour').val();
            if (jQuery(this).val() == '0') {
                ResourceTimeline.LoadData(widthTimeTypes[selectedType], false);
            } else {
                ResourceTimeline.LoadData(widthTimeTypes[selectedType], true);
            }
        });

        var selectedType = $('#Hour').val();
        $('#Hour').on("change", function () {
            $('#schedule').empty();
            if (jQuery('input[name="mutiple"]:checked').val() == '0') {
                ResourceTimeline.LoadData(widthTimeTypes[jQuery(this).val()], false);
            } else {
                ResourceTimeline.LoadData(widthTimeTypes[jQuery(this).val()], true);
            }
        });

        $('input[name="mutiple"]').on("change", function () {
            $('#schedule').empty();
            selectedType = jQuery('input[name="timeType"]:checked').val();
            if (jQuery(this).val() == '0') {
                ResourceTimeline.LoadData(widthTimeTypes[selectedType], false);
            } else {
                ResourceTimeline.LoadData(widthTimeTypes[selectedType], true);
            }

        });

        ResourceTimeline.LoadData(widthTimeTypes[selectedType], false);

        $("#filter_cmn_branch_id").on("change", function () {
            ResourceTimeline.LoadEmployeeDropDown($(this).val());
        });

        $("#iFilterNextDate").on("click", function () {
            $('#filter_date').val(moment($('#filter_date').val(), 'YYYY-MM-DD').add(1, 'days').format("YYYY-MM-DD"));
        });
        $("#iFilterPrvDate").on("click", function () {
            $('#filter_date').val(moment($('#filter_date').val(), 'YYYY-MM-DD').subtract(1, 'days').format("YYYY-MM-DD"));
        });

        $("#btnPreviewInvoice").on('click', function () {
            window.open(JsManager.BaseUrl() + '/download-service-invoice-order?serviceBookingInfoId=' + $("#filter_booking_info_id").val());
        });

        $("#btnViewBookingNo").on('click', function () {
            if ($("#filter_date").val() == "") {
                Message.Warning("Date is mandatory");
            } else {
                ResourceTimeline.LoadData(widthTimeTypes[selectedType], false);
            }
        });



        //start booking add/edit/delete
        BookingManager.LoadZoneDropDown();
        // BookingManager.LoadBranchDropDown();
        // BookingManager.LoadServiceCategoryDropDown();
        BookingManager.LoadCustomerDropDown();
        BookingManager.LoadPaymentTypeDropDown();

        $("#btnAddSchedule").on("click", function () {
            // $("#zone_id").val($("#filter_zone_id").val());
            $("#cmn_branch_id").val($("#filter_cmn_branch_id").val());
            scheduleTempData = null;
            $("#frmAddScheduleModal").modal('show');
        })

        // $(document).ready(function () {
        //     $("#cmn_branch_id").val($("#filter_cmn_branch_id").val());
        //     scheduleTempData = null;
        //     $("#frmAddScheduleModal").modal('show');
        // });
        



        $("#iNextDate").on("click", function () {
            $('#divServiceDate').datetimepicker('destroy');
            var nextDate = moment($('#serviceDate').val(), 'YYYY-MMM-DD').add(1, 'days');
            BookingManager.ServiceDatePicker(nextDate);
        });
        $("#iPrvDate").on("click", function () {
            var nextDate = moment($('#serviceDate').val(), 'YYYY-MM-DD').subtract(1, 'days');
            $('#divServiceDate').datetimepicker('destroy');
            BookingManager.ServiceDatePicker(nextDate);
        });


        $("#sch_service_category_id").on("change", function () {
            BookingManager.LoadServiceDropDown($(this).val());
        });

        $("#sch_service_id").on("change", function () {
            BookingManager.LoadEmployeeDropDown($(this).val());
        });

        $(".serviceInput").on("change", function () {
            let selectedPropId = $(this).attr('id');
            if (selectedPropId == "cmn_branch_id") {
                $("#sch_employee_id").val('');
                $("#sch_service_category_id").val('');
                $("#sch_service_id").val('');
            }
            else if (selectedPropId == "sch_service_category_id") {
                $("#sch_employee_id").val('');
                $("#sch_service_id").val('');
            } else if (selectedPropId == "sch_service_id") {
                $("#sch_employee_id").val('');
                BookingManager.LoadServiceTimeSlot($(this).val(), $("#sch_employee_id").val());
            } else if (selectedPropId == "sch_employee_id") {
                BookingManager.LoadServiceTimeSlot($("#sch_service_id").val(), $(this).val());
            }

            //set service price
            $("#paid_amount").val(0);
            if (selectedPropId == "sch_employee_id") {
                $("#paid_amount").val($('option:selected', this).data('price'));
            }
        });

        $(".iChangeDate").on("click", function () {
            BookingManager.LoadServiceTimeSlot($("#sch_service_id").val(), $("#sch_employee_id").val());
        });


        //Add schedule modal hidden
        $("#frmAddScheduleModal").on('hidden.bs.modal', function () {
            BookingManager.ResetBookingForm();
        });

        $("#btn-schedule-edit").on("click", function () {
            JsManager.StartProcessBar();
            $("#modalViewScheduleDetails").modal('hide');
            var btnScheduleEdit = 1;
            $("#modalViewScheduleDetails").on('hidden.bs.modal', function () {
                if (btnScheduleEdit == 1) {
                    $("#frmAddScheduleModal").modal('show');
                    JsManager.EndProcessBar();
                    btnScheduleEdit = 0;
                }
            });

            var serviceDate = moment(scheduleTempData.date);
            $('#divServiceDate').datetimepicker('destroy');
            BookingManager.ServiceDatePicker(serviceDate);
            $("#serviceDate").val(serviceDate.format("YYYY-MM-DD"));

            $("#cmn_branch_id").val(scheduleTempData.cmn_branch_id);
            $("#sch_service_category_id").val(scheduleTempData.sch_service_category_id);
            $("#cmn_customer_id").val(scheduleTempData.cmn_customer_id).selectpicker('refresh');
            $("#cmn_payment_type_id").val(scheduleTempData.cmn_payment_type_id);
            $("#paid_amount").val(scheduleTempData.paid_amount);
            $("#status").val(scheduleTempData.status);
            $("#monthly").val(scheduleTempData.monthly);
            $("#remarks").val(scheduleTempData.remarks);
            BookingManager.LoadServiceDropDown($("#sch_service_category_id").val(), scheduleTempData.sch_service_id);
            BookingManager.LoadEmployeeDropDown($("#sch_service_id").val(), scheduleTempData.sch_employee_id);
            BookingManager.LoadServiceTimeSlot($("#sch_service_id").val(), $("#sch_employee_id").val());
            $.each($("#divServiceAvaiableTime > .divTimeSlot"), function (i, v) {
                if ($(v).attr('title') == scheduleTempData.start_time + "-" + scheduleTempData.end_time) {
                    $(v).addClass("divTimeSlotActive");
                    $(v).addClass("divTimeSlotActive");
                    $(v).find("input").attr("checked", "checked");
                }
            });
            $("#sch_service_id").selectpicker('refresh');
            $("#sch_employee_id").selectpicker('refresh');

        });

        //btn schedule delete
        $("#btn-schedule-delete").on("click", function () {
            if (scheduleTempData != null) {
                BookingManager.DeleteBooking(scheduleTempData.id);
                $("#modalViewScheduleDetails").modal('hide');
            }
        });

        //btn schedule cancel
        $("#btn-schedule-cancel").on("click", function () {
            if (scheduleTempData != null) {
                BookingManager.CancelBooking(scheduleTempData.id);
                $("#modalViewScheduleDetails").modal('hide');
            }
        });

        //btn schedule cancel
        $("#btn-schedule-done").on("click", function () {
            if (scheduleTempData != null) {
                BookingManager.DoneBooking(scheduleTempData.id);
                $("#modalViewScheduleDetails").modal('hide');
            }
        });

        //modal add customer
        $("#btnAddNewCustomer").on("click", function () {
            $("#modalAddCustomer").modal('show');
            $("#modalAddCustomer").on('hidden.bs.modal', function () {
                $("#frmAddScheduleModal").css({
                    'overflow-x': 'hidden',
                    'overflow-y': 'auto'
                });
            });
        });


        //save or update booking
        JsManager.JqBootstrapValidation('#inputFormBooking', (form, event) => {
            event.preventDefault();
            if (scheduleTempData != null) {
                BookingManager.UpdateBooking(form, scheduleTempData.id);
            } else {
                BookingManager.AddBooking(form, 0);
            }
        });
        //end booking add/edit/delete


        //start custome
        initTelephone = window.intlTelInput(document.querySelector("#phone_no"), {
            allowDropdown: true,
            autoHideDialCode: false,
            dropdownContainer: document.body,
            excludeCountries: [],
            formatOnDisplay: false,
            geoIpLookup: function (callback) {
                var jsonParam = '';
                var serviceUrl = "get-requested-country-code";
                JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == 1) {
                        callback(jsonData.data);
                    } else {
                        callback("US");
                    }
                }
                function onFailed(xhr, status, err) {
                }
            },
            initialCountry: "auto",
            nationalMode: true,
            placeholderNumberType: "MOBILE",
            separateDialCode: true,
            utilsScript: "js/lib/tel-input/js/utils.js",
        });

        Customer.LoadUserDropdown();

        //save customer
        JsManager.JqBootstrapValidation('#inputFormCustomer', (form, event) => {
            event.preventDefault();
            Customer.Save(form);
        });

        //end customer


    });


    //on cahnge zone -> load reated branches
    $("#zone_id").on("change", function () {
        BookingManager.LoadBranchDropDown($(this).val());
    });

    //on cahnge branch -> load reated service
    $("#cmn_branch_id").on("change", function () {
        BookingManager.LoadServiceCategoryDropDown($(this).val());
    });



    window.onload = (event) => {
        BookingManager.ServiceDatePicker(new Date());
    };

    $(document).on("click", ".divTimeSlot", function () {
        $(".divTimeSlot").removeClass('border-red');
    });

    $(document).on("click", ".divTimeSlot", function () {
        $(this).find('input').prop('checked', true);
        $('.divTimeSlot').removeClass('divTimeSlotActive');
        $(this).addClass('divTimeSlotActive');
        BookingManager.SetServiceProperty($("#serviceDate").val(), $(this).find('.divStartTime').text());
    });


    $(document).on("click", "#add-service-btn", function () {
        var branch = $("#cmn_branch_id");
        var categoryId = $("#sch_service_category_id");
        var serviceId = $("#sch_service_id");
        var employeeId = $("#sch_employee_id");
        var serviceTime = $("input[name='service_time']");

        if (!branch.val()) {
            Message.Warning('Branch is required');
        }
        else if (!categoryId.val()) {
            Message.Warning('Category is required');
        }
        else if (!serviceId.val()) {
            Message.Warning('Service is required');
        }
        else if (!employeeId.val()) {
            Message.Warning('Staff is required');
        } else if (serviceTime.length < 1 || typeof $("input[name='service_time']:checked").val() == 'undefined') {
            Message.Warning("Select service time.");
            $(".divTimeSlot").addClass('border-red');
        } else {
            BookingManager.AddBookingSchedule();
            return true;
        }
    });

    $(document).on("click", "#btn-apply-coupon", function () {
        if ($("#cmn_customer_id").val()) {
            BookingManager.GetCouponAmount();
        } else {
            Message.Warning("Select customer first.");
        }
    });

    var BookingManager = {
        ResetBookingForm: function () {
            $("#inputFormBooking").trigger('reset');
            var todayDate = moment(new Date(), 'YYYY-MM-DD');
            $('#divServiceDate').datetimepicker('destroy');
            BookingManager.ServiceDatePicker(todayDate);
            $("#divServiceAvaiableTime").empty();
            // $("#sch_service_id").selectpicker('refresh');
            // $("#sch_employee_id").selectpicker('refresh');
            // $("#cmn_customer_id").selectpicker('refresh');
            bookingList = [];
            $("#iSelectedServiceList").empty();
            $("#div-service-summary").addClass('d-none');
        },
        ServiceDatePicker: function (startDate) {
            const date = new Date()
            const max_date = new Date(new Date(date).setMonth(date.getMonth() + 1))
            $('#divServiceDate').datetimepicker({
                format: 'Y-m-d',
                inline: true,
                timepicker: false,
                minDate: new Date(),
                startDate: startDate._d,
                maxDate : max_date,
                onChangeDateTime: function (dp, $input) {
                    $("#serviceDate").val($input.val());
                    BookingManager.SetServiceProperty($input.val());
                    BookingManager.LoadServiceTimeSlot($("#sch_service_id").val(), $("#sch_employee_id").val())
                }
            });
            BookingManager.SetServiceProperty(startDate);
        },
        SetServiceProperty: function (startDate, time) {
            let longDate = moment(startDate).format('dddd, MMMM, DD, yyyy');
            $("#serviceDate").val(JsManager.DateFormatDefault(startDate));
            $("#divDaysName").text(longDate);
            if (time) {
                $("#iSelectedServiceText").text("You've Selected " + time + " On " + longDate);
            } else {
                $("#iSelectedServiceText").text("You've Selected " + longDate);
            }
        },

        LoadZoneDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-zone";
            // var serviceUrl = "get-branch-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#zone_id", jsonData.data);
                BookingManager.LoadBranchDropDown($("#zone_id").val());
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadBranchDropDown: function (zoneId) {
            var jsonParam = '';
            var serviceUrl = "get-site-branch";
            // var serviceUrl = "get-branch-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                // JsManager.PopulateCombo("#cmn_branch_id", jsonData.data);
                var filteredBranches = jsonData.data.filter(function (branch) {
                    return branch.zone_id == zoneId; // Assuming 'branch_id' is a property of the category
                });
                console.log('filteredBranches', filteredBranches);
                console.log('data', jsonData.data);
                JsManager.PopulateCombo("#cmn_branch_id", filteredBranches, "اختر فئة", '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadServiceCategoryDropDown: function (branchId) {
            var jsonParam = '';
            var serviceUrl = "get-site-service-category";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                
                var filteredCategories = jsonData.data.filter(function (category) {
                    return category.cmn_branch_id == branchId; // Assuming 'branch_id' is a property of the category
                });
                JsManager.PopulateCombo("#sch_service_category_id", filteredCategories, "اختر فئة", '');


                // JsManager.PopulateCombo("#sch_service_category_id", jsonData.data, "Select One", '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadServiceDropDown: function (categoryId, selectedServiceId) {
            var jsonParam = { sch_service_category_id: categoryId };
            var serviceUrl = "get-service-by-category-dropdown";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                var cbmOptions = "<option data-price='0' value=''>اختر خدمة</option>";
                $.each(jsonData.data, function () {
                    cbmOptions += '<option ' + (selectedServiceId == this.id ? "selected" : "") + ' data-price="' + this.fees + '" value=\"' + this.id + '\">' + this.name + '</option>';
                });
                $("#sch_service_id").html(cbmOptions);
                // $("#sch_service_id").selectpicker('refresh');
                // setTimeout(function () {
                //     $select.selectpicker('refresh');
                // }, 200); 
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadEmployeeDropDown: function (serviceId, selectedEmployeeId) {
            var jsonParam = { sch_service_id: serviceId, cmn_branch_id: $("#cmn_branch_id").val() };
            var serviceUrl = "get-employee-by-service";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                currentEmpList = jsonData.data;
                var cbmOptions = "<option data-price='0' value=''>اختر الحجز</option>";
                $.each(jsonData.data, function () {
                    cbmOptions += '<option ' + (selectedEmployeeId == this.id ? "selected" : "") + ' data-price="' + this.fees + '" value=\"' + this.id + '\">' + this.name + '</option>';
                });
                $("#sch_employee_id").html(cbmOptions);
                // $("#sch_employee_id").selectpicker('refresh');
                // setTimeout(function () {
                //     $select.selectpicker('refresh');
                // }, 200); 
                
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadCustomerDropDown: function (nowInsertedCustomerId) {
            var jsonParam = '';
            var serviceUrl = "get-customer-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateComboSelectPicker("#cmn_customer_id", jsonData.data, "اختر عميل", '', nowInsertedCustomerId);
                JsManager.PopulateComboSelectPicker("#filter_cmn_customer_id", jsonData.data, "All Customer", '0');
                $("#cmn_customer_id").selectpicker('refresh');
                $("#filter_cmn_customer_id").selectpicker('refresh');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadPaymentTypeDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-payment-type-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#cmn_payment_type_id", jsonData.data, "اختر طريقة الدفع", '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadServiceTimeSlot: function (serviceId, employeeId) {

            if (employeeId > 0 && serviceId > 0 && $("#serviceDate").val() && $("#cmn_branch_id").val() > 0) {
                JsManager.StartProcessBar();
                var jsonParam = {
                    sch_service_id: serviceId,
                    sch_employee_id: employeeId,
                    date: $("#serviceDate").val(),
                    cmn_branch_id: $("#cmn_branch_id").val()
                };
                var serviceUrl = "get-site-service-time-slot";
                JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);
                function onSuccess(jsonData) {
                    if (jsonData.status == 1) {
                        $("#divServiceAvaiableTime").empty();
                        $.each(jsonData.data, function (i, v) {
                            let disabledClass = "";
                            let disabledServiceText = "";
                            if (v.is_avaiable == 0) {
                                disabledClass = "disabled-service";
                                disabledServiceText = "disabled-service-text";
                            }
                            let serviceTime = v.start_time + '-' + v.end_time;
                            $("#divServiceAvaiableTime").append(
                                '<div class="divTimeSlot ' + disabledClass + '" title="' + serviceTime + '">' +
                                '<div class="float-left w100">' +
                                '<div class="float-left">' +
                                '<input type="radio" class="serviceTime d-none" name="service_time" value="' + serviceTime + '"/>' +
                                '</div>' +
                                '<div class="float-left cp divStartTime text-center w100 ' + disabledServiceText + '">' + moment('1990-01-01 ' + v.start_time).format('hh:mm A') + '</div>' +
                                '</div>' +
                                '</div>');
                        });
                    }
                    JsManager.EndProcessBar();
                }
                function onFailed(xhr, status, err) {
                    $("#divServiceAvaiableTime").empty();
                    if (xhr.responseJSON.status == 5) {
                        $("#divServiceAvaiableTime").append('<div class="mt-3">' + xhr.responseJSON.data + '</div>');
                    } else if (xhr.responseJSON.status == 2) {
                        //service is not available today
                    } else {
                        Message.Exception(xhr);
                    }
                    JsManager.EndProcessBar();
                }
            } else {
                $("#divServiceAvaiableTime").empty();
            }
        },
        AddBooking: function (form, isForceBooking) {
            if (isForceBooking == 1 || Message.Prompt()) {
                JsManager.StartProcessBar();

                const paid_amount_value = $("#paid_amount").val();
                if (bookingList.length < 1)
                    BookingManager.AddBookingSchedule()
                let bookingData = {
                    cmn_customer_id: $("#cmn_customer_id").val(),
                    cmn_payment_type_id: $("#cmn_payment_type_id").val(),
                    paid_amount: paid_amount_value,
                    status: $("#status").val(),
                    monthly: $("#monthly").val(),
                    remarks: $("#remarks").val(),
                    coupon_code: $("#coupon_code").val(),
                    cmn_branch_id: $("#filter_cmn_branch_id").val(),
                    isForceBooking: isForceBooking,
                    items: []
                };
                $.each(bookingList, function (i, v) {
                    let obj = {
                        cmn_branch_id: v.branchId,
                        sch_service_category_id: v.categoryId,
                        sch_service_id: v.serviceId,
                        service_name: v.service_name,
                        sch_employee_id: v.employeeId,
                        service_date: v.serviceDate,
                        service_time: v.serviceTime
                    };
                    bookingData.items.push(obj);
                });

                var jsonParam = {
                    bookingData: bookingData

                };
                var serviceUrl = "save-service-booking";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        if (scheduleClickedTempData != null) {
                            scheduleTable.deleteSchedule(scheduleTable, scheduleClickedTempData.item, scheduleClickedTempData.data);
                            scheduleClickedTempData = null;
                        }
                        let data = [];
                        $.each(jsonData.data.data, function (i, v) {
                            $.each(v.booking_service, function (si, sv) {
                                var obj = {
                                    branch: v.branch,
                                    designation: v.designation,
                                    employee: v.employee,
                                    id: v.id,
                                    image_url: v.image_url
                                };

                                let serviceInfo = [];
                                serviceInfo.push(sv);
                                obj.booking_service = serviceInfo;
                                data.push(obj);
                            });
                        });

                        $.each(data, function (i, v) {
                            let serviceData = [];
                            serviceData.push(v);
                            ResourceTimeline.AddNewSchedule(serviceData);
                        });

                        BookingManager.ResetBookingForm();
                        $("#inputFormBooking").modal('hide');

                        window.open(JsManager.BaseUrl() + '/download-service-invoice-order?serviceBookingInfoId=' + jsonData.booking_info_id)
                    } else if (jsonData.status == "-1") {
                        if (Message.Prompt(jsonData.data)) {
                            BookingManager.AddBooking(form, 1);
                        }
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
        UpdateBooking: function (form, id, isForceBooking) {
            if (isForceBooking == 1 || Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&id=" + id + "&isForceBooking=" + isForceBooking;
                var serviceUrl = "update-service-booking";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        if (scheduleClickedTempData != null) {
                            scheduleTable.deleteSchedule(scheduleTable, scheduleClickedTempData.item, scheduleClickedTempData.data);
                            scheduleClickedTempData = null;
                        }
                        ResourceTimeline.AddNewSchedule(jsonData.data.data)
                        BookingManager.ResetBookingForm();
                        $("#inputFormBooking").modal('hide');
                    } else if (jsonData.status == "-1") {
                        if (Message.Prompt(jsonData.data)) {
                            BookingManager.UpdateBooking(form, id, 1);
                        }
                    } else {
                        Message.Error("update");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },

        DeleteBooking: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: id };
                var serviceUrl = "delete-service-booking";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        if (scheduleClickedTempData != null) {
                            scheduleTable.deleteSchedule(scheduleTable, scheduleClickedTempData.item, scheduleClickedTempData.data);
                            scheduleClickedTempData = null;
                            scheduleTempData = null;
                        }

                    } else {
                        Message.Error("delete");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },

        DoneBooking: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                // let emailNotify = $("#view_schedule_email_notify").prop('checked');
                // emailNotify = emailNotify ? 1 : null;
                var jsonParam = { id: id, email_notify: null };
                var serviceUrl = "done-service-booking";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("Service Successfully Done.");
                        if (scheduleClickedTempData != null) {
                            scheduleTable.deleteSchedule(scheduleTable, scheduleClickedTempData.item, scheduleClickedTempData.data);
                            scheduleClickedTempData = null;
                            scheduleTempData = null;
                        }
                        ResourceTimeline.AddNewSchedule(jsonData.data.data);
                    } else {
                        Message.Error("Failed to Save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },

        CancelBooking: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                // let emailNotify = $("#view_schedule_email_notify").prop('checked');
                // emailNotify = emailNotify ? 1 : null;
                var jsonParam = { id: id, email_notify: null };
                var serviceUrl = "cancel-service-booking";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("cancel");
                        if (scheduleClickedTempData != null) {
                            scheduleTable.deleteSchedule(scheduleTable, scheduleClickedTempData.item, scheduleClickedTempData.data);
                            scheduleClickedTempData = null;
                            scheduleTempData = null;
                        }
                        ResourceTimeline.AddNewSchedule(jsonData.data.data);
                    } else {
                        Message.Error("cancel");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },

        AddBookingSchedule: function () {
            if (bookingList.length > 0) {
                const chkVal = bookingList.filter(function (item, ind) {
                    if (item.branchId != $("#cmn_branch_id").val()) {
                        Message.Warning("You can't add different branches service in the same order");
                        return true;
                    }
                    return item.branchId == $("#cmn_branch_id").val() &&
                        item.categoryId == $("#sch_service_category_id").val() &&
                        item.serviceId == $("#sch_service_id").val() &&
                        item.employeeId == $("#sch_employee_id").val() &&
                        item.serviceTime == $("input[name='service_time']:checked").val() &&
                        item.serviceDate == $("#serviceDate").val();
                });

                if (chkVal.length > 0) {
                    Message.Warning("This is already exists in your cart");
                    return false;
                }
            }
            var currentEmp = currentEmpList.filter(function (emp) { return emp.id == $("#sch_employee_id").val() })[0];
            bookingList.push({
                branchId: $("#cmn_branch_id").val(),
                categoryId: $("#sch_service_category_id").val(),
                serviceId: $("#sch_service_id").val(),
                service_name: $("#sch_service_id option:selected").text(),
                employeeId: $("#sch_employee_id").val(),
                employee_name: currentEmp.name,
                employee_rate: parseFloat(currentEmp.fees),
                serviceTime: $("input[name='service_time']:checked").val(),
                serviceDate: $("#serviceDate").val(),
                currency: currentEmp.currency,
            });
            BookingManager.DrawServiceTable();
            $("#div-service-summary").removeClass('d-none');
            return bookingList;
        },

        DrawServiceTable: function () {
            $('#iSelectedServiceList').empty();
            subtotal = 0;
            $("#coupon_code").val('');
            $("#service-discount-amount").text(currency + ' ' + 0);
            $.each(bookingList, function (ind, item) {
                var $delItem = $('<i class="fa fa-trash text-danger cursor-pointer"></i>');
                $delItem.on("click", function () {
                    BookingManager.RemoveBookingSchedule(ind);
                });
                var $wrap = $('<tr>' +
                    '<td class="text-center">' + (ind + 1) + '</td>' +
                    '<td>' + item.service_name + '</td>' +
                    '<td>' + item.employee_name + '</td>' +
                    '<td>' + item.serviceDate + '</td>' +
                    '<td>' + item.serviceTime + '</td>' +
                    '<td>' + item.currency + " " + item.employee_rate + '</td>' +
                    '<td class="text-center"></td>' +
                    '</tr>');
                $wrap.find('td:last-child').append($delItem);
                $('#iSelectedServiceList').append($wrap);

                subtotal = parseFloat(parseFloat(subtotal) + parseFloat(item.employee_rate), 0);
                currency = item.currency;
            });

            $("#service-total-amount").text(currency + " " + subtotal);
            $("#service-payable-amount").text(currency + " " + subtotal);
            $("#paid_amount").val(subtotal);
        },

        RemoveBookingSchedule: function (ind) {
            if (bookingList[ind] != undefined) {
                bookingList = bookingList.filter(function (item, index) {
                    return index != ind;
                });
            }
            BookingManager.DrawServiceTable();
            return bookingList;

        },
        GetCouponAmount: function () {
            var jsonParam = {
                couponCode: $("#coupon_code").val(),
                orderAmount: subtotal,
                cmn_customer_id: $("#cmn_customer_id").val()
            };
            var serviceUrl = "get-coupon-amount-from-admin";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                if (jsonData.status == 1) {
                    $("#service-discount-amount").text(currency + ' ' + jsonData.data);
                    $("#service-payable-amount").text(currency + ' ' + parseFloat(parseFloat(subtotal) - parseFloat(jsonData.data)).toFixed(2));
                    $("#paid_amount").val(parseFloat(parseFloat(subtotal) - parseFloat(jsonData.data)).toFixed(2));
                }
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

    };

    var Customer = {
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&phone_no=" + $('#phone_no').val();
                var serviceUrl = "customer-create";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        BookingManager.LoadCustomerDropDown(jsonData.data.cmn_customer_id)
                        form.trigger('reset');
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
        LoadUserDropdown: function () {
            var jsonParam = '';
            var serviceUrl = "get-customer-user";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                var cbmOptions = '<option value="">Unknown User</option>';
                cbmOptions += '<option value="0">Create System User(Pass:12345678)</option>';
                $.each(jsonData.data, function () {
                    cbmOptions += '<option value=\"' + this.id + '\">' + this.name + '</option>';
                });
                $("#user_id").html(cbmOptions);
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

    };



    var ResourceTimeline = {
        ServiceStatus: function (status) {
            var serviceStatus = ['Pending', 'Processing', 'Approved', 'Cancel', 'Done'];
            return serviceStatus[status];
        },
        GetTitle: function (title) {
            return '<span class="task_title">' + title + '<span>';
        },
        GetScheduleBgColorClass: function (status) {
            var itemClass = " bg_new";
            if (status == 0) {
                itemClass = " bg_pending";
            } else if (status == 1) {
                itemClass = " bg_processing";
            } else if (status == 2) {
                itemClass = " bg_approved";
            }
            else if (status == 3) {
                itemClass = " bg_cancel";
            }
            else if (status == 4) {
                itemClass = " bg_done";
            }
            return itemClass;
        },

        LoadData: function (timeType, multiple) {
            $('#reload_timeline').prop("disabled", true).text("Loading..");
            JsManager.StartProcessBar();
            $("#scheduleContent").html('<div id="schedule"></div>');

            let bookingId = $("#filter_booking_id").val();
            if (bookingId == "" || bookingId == null)
                bookingId = 0;
            var jsonParam = {
                cmn_branch_id: $("#filter_cmn_branch_id").val(),
                sch_employee_id: $("#filter_sch_employee_id").val(),
                date: $("#filter_date").val(),
                cmn_customer_id: $("#filter_cmn_customer_id").val(),
                serviceBookingId: bookingId
            };
            var serviceUrl = 'get-employee-schedule-calendar';
            JsManager.SendJson("GET", serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                if (jsonData.status == 1 && jsonData.serviceTimeSlot) {
                    ResourceTimeline.Data = [];
                    let totalBooking = 0;
                    let cancelBooking = 0;
                    let doneBooking = 0;
                    let approvedBooking = 0;
                    let processingBooking = 0;
                    let pendingBooking = 0;
                    var data = jsonData.data;
                    $.each(data, function (ind, item) {
                        var user_info = {
                            designation: item.designation,
                            employee: item.employee,
                            Name: item.Name,
                            branch: item.branch,
                            image: item.image_url,
                        };
                        var scheduleData = [];

                        //count service
                        if (item.booking_service) {
                            let service = item.booking_service;
                            totalBooking += service.length;
                            cancelBooking += service.filter(f => f.status == 3).length;
                            doneBooking += service.filter(f => f.status == 4).length;
                            approvedBooking += service.filter(f => f.status == 2).length;
                            processingBooking += service.filter(f => f.status == 1).length;
                            pendingBooking += service.filter(f => f.status == 0).length;
                        }

                        $.each(item.booking_service, function (indW, task) {
                            var itemClass = ResourceTimeline.GetScheduleBgColorClass(task.status);
                            scheduleData.push({
                                id: item.id,
                                text: ResourceTimeline.GetTitle(task.service + " [" + task.customer + "] [" + JsManager.MomentTime(task.start_time).format('H:m') + '-' + JsManager.MomentTime(task.end_time).format('H:m') + "]"),
                                class: itemClass,
                                start: moment(task.date + ' ' + task.start_time).format('YYYY/MM/DD HH:mm'),
                                end: moment(task.date + ' ' + task.end_time).format('YYYY/MM/DD HH:mm'),
                                data: {
                                    item_type: 'Task',
                                    task: task,
                                    user: user_info,
                                    item_class: itemClass
                                }
                            });
                        });

                        var employeeData = {
                            title: '<img src="' + JsManager.BaseUrl() + "/" + item.image_url + ' " class="resource-image"> <span class="resource-name">' + item.employee.substr(0, 27) + '<span>' + (item.designation == null ? "Unknown Destination" : item.designation.substr(0, 35)) + '<br>' + item.branch.substr(0, 35) + '</span></span>',
                            // title: '<img src="' + JsManager.BaseUrl() + "/" + item.image_url + ' " class="resource-image"> <span class="resource-name" style="color:#1269DB;">' + item.employee.substr(0, 40) + '<span>' + (item.designation == null ? "Unknown Destination" : item.designation.substr(0, 35)) + '<br>' + item.branch.substr(0, 35) + '</span></span>',
                            impossibleDate: [],
                            businessHours: ResourceTimeline.BusinessHours(),
                            schedule: scheduleData,
                            id: item.id
                        };
                        ResourceTimeline.Data.push(employeeData);
                    });
                    scheduleTable = $("#schedule").timeSchedule({
                        today: moment(new Date()).format('YYYY/MM/DD'),
                        nowTime: moment(new Date()).format('HH:mm'),
                        startDate: moment($('#filter_date').val()).format('YYYY/MM/DD'),
                        endDate: moment($('#filter_date').val()).format('YYYY/MM/DD'),
                        weekday: ['Sun.', 'Mon.', 'Tue.', 'Wed.', 'Thu.', 'Fri.', 'Sat.'],
                        startTime: JsManager.MomentTime(jsonData.serviceTimeSlot.startTime ?? "00:00:00").format("HH:mm"),
                        endTime: JsManager.MomentTime(jsonData.serviceTimeSlot.endTime ?? "233:59:00").format("HH:mm"),
                        widthTimeX: 35,
                        widthTime: 60 * timeType,
                        timeLineY: 70,
                        verticalScrollbar: 10,
                        timeLineBorder: 2,
                        dataWidth: 250,
                        // dataWidth: 350,
                        nextNo: 2,
                        debug: "",
                        multiple: multiple,
                        rows: ResourceTimeline.Data,
                        allowModifyTask: true,
                        allowDeleteTask: false,
                        displayTime: false,
                        holidayList: [],
                        dateClass: "",
                        init_data: function (node, data) {

                        },
                        click: function (item, data) {

                            ResourceTimeline.ViewSelectedScheduleData(item, data);
                        },
                        append: function (node, data) {

                        },
                        timeClick: function (element, data) {

                        },
                        dateClick: function (date) {

                        },
                        timeDrag: function (data) {
                            scheduleClickedTempData = { data: data, item: scheduleTable.find('.newAdd') };
                            ResourceTimeline.ViewSelectedScheduleData(scheduleTable.find('.newAdd'), data);

                        },
                        titleClick: function (data) {

                        },
                        change: function (data) {

                        },
                        delete: function (data) {
                        }
                    });
                    $('#reload_timeline').prop("disabled", false).text("Load");
                    JsManager.EndProcessBar();
                    $("#schedule > .sc_menu:nth-child(2) .sc_header_cell").html('<div style="padding-top:10px;padding-left:10px;">Employee & Time</div>');

                    $("#total-booking").text(totalBooking);
                    $("#cancel-booking").text(cancelBooking);
                    $("#done-booking").text(doneBooking);
                    $("#approved-booking").text(approvedBooking);
                    $("#processing-booking").text(processingBooking);
                    $("#pending-booking").text(pendingBooking);
                }
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
                $('#reload_timeline').prop("disabled", false).text("Load");
                JsManager.EndProcessBar();
            }
        },

        ViewSelectedScheduleData: function (item, scheduleData) {

            if (typeof scheduleData.data.task != 'undefined') {
                JsManager.StartProcessBar();
                var jsonParam = { sch_service_booking_id: scheduleData.data.task.id };
                var serviceUrl = "get-booking-info-by-service-id";
                JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);
                function onSuccess(jsonData) {
                    if (jsonData.status == 1) {
                        scheduleClickedTempData = { data: scheduleData, item: item };
                        $("#modalViewScheduleDetails").modal('show');
                        var data = jsonData.data;
                        scheduleTempData = data;
                        $("#scheduleEmployeeImage").prop("src", JsManager.BaseUrl() + "/" + data.image_url);
                        $("#scheduleEmployee").text(data.employee);
                        $("#scheduleSpecialist").text(data.specialist);
                        $("#scheduleCustomer").text(data.customer);
                        $("#scheduleBranch").text(data.branch);
                        $("#scheduleCustomerPhone").text(data.phone_no);
                        // $("#scheduleCustomerEmail").text(data.email);
                        $("#scheduleServiceBookingDate").text(moment(data.created_at).format('YYYY-MM-DD'));
                        $("#scheduleServiceDate").text(moment(data.date).format('YYYY-MM-DD'));
                        $("#scheduleService").text(data.service);
                        $("#scheduleServiceTime").text(JsManager.MomentTime(data.start_time).format('HH:mm') + " | " + JsManager.MomentTime(data.end_time).format('HH:mm'));
                        $("#schedulePaidAmount").text(data.paid_amount);
                        $("#scheduleRemarks").text(data.remarks);
                        $("#scheduleServiceStatus").text(ResourceTimeline.ServiceStatus(data.status));
                    }
                    JsManager.EndProcessBar();
                }
                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            } else {
                //new
                $("#frmAddScheduleModal").modal('show');
                var serviceDate = moment($("#filter_date").val(), 'YYYY-MM-DD');
                $('#divServiceDate').datetimepicker('destroy');
                BookingManager.ServiceDatePicker(serviceDate);
                $("#serviceDate").val(serviceDate.format("YYYY-MM-DD"));

            }
        },

        BusinessHours: function () {
            return [{
                dow: ['0'],
                start: '00:00',
                end: '24:00'
            },
            {
                dow: ['1'],
                start: '00:00',
                end: '24:00'
            },
            {
                dow: ['2'],
                start: '00:00',
                end: '24:00'
            },
            {
                dow: ['3'],
                start: '00:00',
                end: '24:00'
            },
            {
                dow: ['4'],
                start: '00:00',
                end: '24:00'
            },
            {
                dow: ['5'],
                start: '00:00',
                end: '24:00'
            },
            {
                dow: ['6'],
                start: '00:00',
                end: '24:00'
            }];
        },

        LoadZoneDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-zone";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {

                JsManager.PopulateCombo("#filter_zone_id", jsonData.data);
                // ResourceTimeline.LoadBranchDropDown($("#filter_zone_id").val());
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadBranchDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-branch";
            // var serviceUrl = "get-branch-dropdown";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#filter_cmn_branch_id", jsonData.data);
                ResourceTimeline.LoadEmployeeDropDown($("#filter_cmn_branch_id").val());
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadEmployeeDropDown: function (branchId) {
            var jsonParam = { branchId: branchId };
            var serviceUrl = "get-employee-dropdown";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.data.length < 2) {
                    JsManager.PopulateComboSelectPicker("#filter_sch_employee_id", jsonData.data);
                } else {
                    JsManager.PopulateComboSelectPicker("#filter_sch_employee_id", jsonData.data, 'All Employee', '0');
                }
                $("#filter_sch_employee_id").selectpicker('refresh');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        AddNewSchedule: function (data) {
            data = data[0];
            var user_info = {
                designation: data.designation,
                employee: data.employee,
                Name: data.Name,
                branch: data.branch,
                image: data.image_url,
            };
            var task = data.booking_service[0];
            var itemClass = ResourceTimeline.GetScheduleBgColorClass(task.status);
            var scheduleData = {
                id: data.id,
                text: ResourceTimeline.GetTitle(task.service + " [" + task.customer + "] [" + JsManager.MomentTime(task.start_time).format('H:m') + '-' + JsManager.MomentTime(task.end_time).format('H:m') + "]"),
                class: itemClass,
                start: moment(task.date + ' ' + task.start_time).format('YYYY/MM/DD HH:mm'),
                end: moment(task.date + ' ' + task.end_time).format('YYYY/MM/DD HH:mm'),
                data: {
                    item_type: 'Task',
                    task: task,
                    user: user_info,
                    item_class: itemClass
                }
            };
            scheduleTable.addSchedule(scheduleTable, scheduleData);
        },


    };
})(jQuery);
