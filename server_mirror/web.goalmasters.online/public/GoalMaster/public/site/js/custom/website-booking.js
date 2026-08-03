
(function ($) {
    "use strict";
    var initTelephone;
    var serviceStepar;
    var isBookingSuccess = false;
    var currentEmpList = [];
    let currency = '';
    let subtotal = 0;
    var bookingList = [];

    $(document).ready(function () {
        serviceStepar = $("#serviceStep").steps({
            headerTag: "h3",
            bodyTag: "section",
            transitionEffect: "slideLeft",
            autoFocus: true,
            /**
             * Triggered when the wizard is initialized.
             *
             * @param {object} event - Event object.
             * @param {number} currentIndex - Current index of the wizard.
             */
            onInit: function (event, currentIndex) {
    
            },
            onStepChanging: function (event, currentIndex, newIndex) {
                if (currentIndex > newIndex)
                    return true;
                var branch = $("#cmn_branch_id");
                var categoryId = $("#sch_service_category_id");
                var serviceId = $("#sch_service_id");
                var employeeId = $("#sch_employee_id");
                var serviceTime = $("input[name='service_time']");
    
                if (currentIndex == 0) {
                    if (!branch.val()) {
                        branch.addClass('border-red');
                    }
                    else if (!categoryId.val()) {
                        categoryId.addClass('border-red');
                    }
                    else if (!serviceId.val()) {
                        serviceId.addClass('border-red');
                    }
                    else if (!employeeId.val()) {
                        employeeId.addClass('border-red');
                    } else if (serviceTime.length < 1 || typeof $("input[name='service_time']:checked").val() == 'undefined' ||
                        $("input[name='service_time']:checked").val() == 'booked'
                    ) {
                        Message.Warning("Select service time.");
                        $(".divTimeSlot").addClass('border-red');
                    } else {
                        SiteManager.GetCustomerLoginInfo();
                        if (bookingList.length < 1)
                            SiteManager.AddBookingSchedule();
                        return true;
                    }
                }
                else if (currentIndex == 1) {
                    var fullName = $("#full_name");
                    var phone = $("#phone_no");
                    var phoneRegex = /^09\d{8}$/; 
    
                    if (!fullName.val()) {
                        fullName.addClass('border-red');
                    }
                    else if (!phone.val()) {
                        phone.addClass('border-red');
                    } else if (!phoneRegex.test(phone.val())) {
                        phone.addClass('border-red');
                        Message.Warning("رقم الجوال غير صحيح يجب أن يبدا ب 09 و يتكون من 10 رقم");
                    }
                    else {
                        SiteManager.is_phone_verified();
                        SiteManager.sendOtp();
                        SiteManager.CalculateServiceSummary();
                        return true;
                    }
                }
                else if (currentIndex == 2) {
                    var verification_status = $("#verification_status");
                    if (verification_status.val() == 'false') {
    
                    }
                    else {
                        return true;
                    }
                }
                else if (currentIndex == 3) {
                    if (isBookingSuccess == false) {
                        SiteManager.SaveBooking();
                    } else {
                        return true;
                    }
                }
                else if (currentIndex == 4) {
                    return true;
                }
            },
            onStepChanged: function (event, currentIndex, priorIndex) {
                var finishButton = $(".actions a[href='#finish']");
                var prevButton = $(".actions a[href='#previous']");
                
                if (finishButton.is(":visible")) {
                    prevButton.hide(); 
                } else {
                    prevButton.show(); 
                }
            },
            onFinished: function (event, currentIndex) {
                window.location = JsManager.BaseUrl() + "/client-dashboard";
            },
            labels: {
                next: "التالي", 
                previous: "السابق", 
                finish: "إنهاء", 
                loading: "جاري التحميل ..."
            }
        });
    
        $(".form-control").on("click", function () {
            $(this).removeClass('border-red');
        });
    
        SiteManager.LoadZoneDropDown();
        SiteManager.PaymentType();
    
        $("#zone_id").on("change", function () {
            SiteManager.LoadBranchDropDown($(this).val());
        });
    
        $("#cmn_branch_id").on("change", function () {
            SiteManager.LoadServiceCategoryDropDown($(this).val());
        });
    
        $("#sch_service_category_id").on("change", function () {
            SiteManager.LoadServiceDropDown($(this).val());
        });
    
        $("#sch_service_id").on("change", function () {
            SiteManager.LoadEmployeeDropDown($(this).val());
        });
    
        $("#iNextDate").on("click", function () {
            $('#divServiceDate').datetimepicker('destroy');
            var nextDate = moment($('#serviceDate').val(), 'Y-M-D').add(1, 'days');
            SiteManager.ServiceDatePicker(nextDate);
        });
    
        $("#iPrvDate").on("click", function () {
            var nextDate = moment($('#serviceDate').val(), 'Y-M-D').subtract(1, 'days');
            if (nextDate >= moment(moment(new Date()).format('Y-M-D'), 'Y-M-D')) {
                $('#divServiceDate').datetimepicker('destroy');
                SiteManager.ServiceDatePicker(nextDate);
            }
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
                SiteManager.LoadServiceTimeSlot($(this).val(), $("#sch_employee_id").val());
            } else if (selectedPropId == "sch_employee_id") {
                SiteManager.LoadServiceTimeSlot($("#sch_service_id").val(), $(this).val());
            }
        });
    
        $(".iChangeDate").on("click", function () {
            SiteManager.LoadServiceTimeSlot($("#sch_service_id").val(), $("#sch_employee_id").val());
        });
    
        var date = new Date();
        SiteManager.ServiceDatePicker(date);
    });
    

    $(document).on('click', "#verify", function () {
        SiteManager.verify_Phone();
    })

    $(document).on('click', "#resend", function () {
        SiteManager.resend_otp();
    })

    $(document).on('click', ".payment-chose-div", function () {
        $(this).find('input').prop('checked', true);
        $(".payment-chose-div").removeClass('payment-chose');
        $(this).addClass('payment-chose');
    });

    $(document).on("click", ".divTimeSlot", function () {
        $(".divTimeSlot").removeClass('border-red');
    });

    $(document).on("click", "#add-service-btn", function () {
        var branch = $("#cmn_branch_id");
        var categoryId = $("#sch_service_category_id");
        var serviceId = $("#sch_service_id");
        var employeeId = $("#sch_employee_id");
        var serviceTime = $("input[name='service_time']");

        if (!branch.val()) {
            branch.addClass('border-red');
        }
        else if (!categoryId.val()) {
            categoryId.addClass('border-red');
        }
        else if (!serviceId.val()) {
            serviceId.addClass('border-red');
        }
        else if (!employeeId.val()) {
            employeeId.addClass('border-red');
        } else if (serviceTime.length < 1 || typeof $("input[name='service_time']:checked").val() == 'undefined' ||
            $("input[name='service_time']:checked").val() == 'booked'
        ) {
            Message.Warning("Select service time.");
            $(".divTimeSlot").addClass('border-red');
        } else {
            SiteManager.AddBookingSchedule();
            return true;
        }
    });

    $(document).on("click", ".divTimeSlot", function () {
        $(this).find('input').prop('checked', true);
        $('.divTimeSlot').removeClass('divTimeSlotActive');
        $(this).addClass('divTimeSlotActive');
        SiteManager.SetServiceProperty($("#serviceDate").val(), $(this).find('.divStartTime').text());
    });

    $(document).on("click", "#btn-apply-coupon", function () {
        SiteManager.GetCouponAmount();
    });


    var SiteManager = {
        GetCouponAmount: function () {
            var jsonParam = {
                couponCode: $("#coupon_code").val(),
                orderAmount: subtotal
            };
            var serviceUrl = "get-coupon-amount";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                if (jsonData.status == 1) {
                    $("#summary-discount").text(currency + '' + jsonData.data);
                    $("#summary-total").text(currency + '' + parseFloat(parseFloat(subtotal) - parseFloat(jsonData.data)).toFixed(2));
                }
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        PaymentType: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-payment-type";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {

                if (jsonData.status == 1) {
                    $.each(jsonData.data, function (i, v) {
                        let typeIcon = '<img src="img/payment-cash.jpeg" />';
                        let checkStatus = "";
                        let activePayment = '';
                        if (v.type == 2) {
                            typeIcon = '<img src="img/payment-paypal.svg" />';
                            checkStatus = 'checked';
                            activePayment = 'payment-chose';
                        } else if (v.type == 3) {
                            typeIcon = '<img src="img/payment-stripe.svg" />';
                        }
                        else if (v.type == 4) {
                            typeIcon = '<img src="img/payment-user-balance.jpeg" />';
                        }

                        $("#divPaymentMethod").append('<div class="payment-chose-div float-start ' + activePayment + '">' +
                            '<input  ' + checkStatus + ' type="radio" name="payment_type" id="payment_type" value="' + v.id + '" class="float-start payment-radio d-none" />' +
                            '<div class="float-start color-black p-2">' + typeIcon + '</div>' +
                            '</div>');

                    });
                }
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
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
                    SiteManager.SetServiceProperty($input.val());
                    SiteManager.LoadServiceTimeSlot($("#sch_service_id").val(), $("#sch_employee_id").val())
                }
            });
            SiteManager.SetServiceProperty(startDate);
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
        LoadServiceCategoryDropDown: function (branchId) {
            var jsonParam = '';
            var serviceUrl = "get-site-service-category";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {


                var filteredCategories = jsonData.data.filter(function (category) {
                    return category.cmn_branch_id == branchId; // Assuming 'branch_id' is a property of the category
                });
                JsManager.PopulateCombo("#sch_service_category_id", filteredCategories, "اختر واحدة", '');

                // JsManager.PopulateCombo("#sch_service_category_id", jsonData.data, "اختر واحدة", '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadServiceDropDown: function (categoryId) {
            var jsonParam = { sch_service_category_id: categoryId };
            var serviceUrl = "get-site-service";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#sch_service_id", jsonData.data, "اختر واحدة", '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadZoneDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-zone";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#zone_id", jsonData.data, "اختر واحدة", '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadBranchDropDown: function (zoneId) {
            var jsonParam = '';
            var serviceUrl = "get-site-branch";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                var filteredBranches = jsonData.data.filter(function (branch) {
                    return branch.zone_id == zoneId; // Assuming 'branch_id' is a property of the category
                });
                JsManager.PopulateCombo("#cmn_branch_id", filteredBranches, "اختر واحدة", '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadEmployeeDropDown: function (serviceId) {
            var jsonParam = { sch_service_id: serviceId, cmn_branch_id: $("#cmn_branch_id").val() };
            var serviceUrl = "get-site-employee-service";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                currentEmpList = jsonData.data;
                JsManager.PopulateCombo("#sch_employee_id", jsonData.data, "اختر واحدة", '');
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
                JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);
                function onSuccess(jsonData) {
                    if (jsonData.status == 1) {
                        $("#divServiceAvaiableTime").empty();
                        $.each(jsonData.data, function (i, v) {
                            let disabledClass = "";
                            let disabledServiceText = "";
                            let serviceTime = v.start_time + '-' + v.end_time;
                            if (v.is_avaiable == 0) {
                                disabledClass = "disabled-service";
                                disabledServiceText = "disabled-service-text";
                                serviceTime = "booked";
                            }

                            $("#divServiceAvaiableTime").append(
                                '<div class="divTimeSlot ' + disabledClass + '" title="' + serviceTime + '">' +
                                '<div class="float-start w-100">' +
                                '<div class="float-start">' +
                                '<input type="radio" class="serviceTime d-none" name="service_time" value="' + serviceTime + '"/>' +
                                '</div>' +
                                '<div class="float-start cp divStartTime text-center w-100 ' + disabledServiceText + '" style="direction: ltr;">' + moment('1990-01-01 ' + v.start_time).format('hh:mm A') + '</div>' +
                                '</div>' +
                                '</div>');
                        });
                    }
                    JsManager.EndProcessBar();
                }
                function onFailed(xhr, status, err) {
                    if (xhr.responseJSON.status == 5) {
                        $("#divServiceAvaiableTime").empty();
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
        SaveBooking: function () {
            return new Promise(function (resolve, reject) {
                if (Message.Prompt()) {
                    JsManager.StartProcessBar();
                    let bookingData = {
                        full_name: $("#full_name").val(),
                        // email: $("#email").val(),
                        phone_no: $("#phone_no").val(),
                        state: $("#state").val(),
                        city: $("#city").val(),
                        postal_code: $("#postal_code").val(),
                        street_address: $("#street_address").val(),
                        service_remarks: $("#service_remarks").val(),
                        payment_type: $("input[name='payment_type']:checked").val(),
                        coupon_code: $("#coupon_code").val(),
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

                    var jsonParam = { bookingData: bookingData };
                    var serviceUrl = "save-site-service-booking";
                    JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);


                    function onSuccess(jsonData) {
                        if (jsonData.status == "1") {
                            Message.Success("save");
                            isBookingSuccess = true;
                            if (jsonData.paymentType == "paypal") {
                                if (jsonData.data.returnUrl.status = 201) {
                                    window.location.href = jsonData.data.returnUrl.data.links[1].href;
                                } else {
                                    //order will be cancel by redirect
                                    SiteManager.CancelBooking(jsonData.data.returnUrl.purchase_units[0].reference_id)
                                }
                            }
                            else if (jsonData.paymentType == "stripe") {
                                window.location.href = jsonData.data.returnUrl.redirectUrl;
                            }
                            else if (jsonData.paymentType == "userBalance") {
                                window.location.href = jsonData.data.returnUrl.redirectUrl;
                            }
                            else {
                                //local payment done
                                serviceStepar.steps("next");
                                isBookingSuccess = false;
                            }
                            JsManager.EndProcessBar();
                        } else {
                            Message.Error("save");
                            JsManager.EndProcessBar();
                        }
                        JsManager.EndProcessBar();
                    }

                    function onFailed(xhr, status, err) {
                        JsManager.EndProcessBar();
                        Message.Exception(xhr);
                    }
                    isBookingSuccess = false;
                }
            });
        },

        CancelBooking: function (bookingId) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { serviceBookingId: bookingId };
                var serviceUrl = "site-cancel-booking";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("Cancel Successfully");
                    } else {
                        Message.Error("save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                    return false;
                }
            }
        },

        GetCustomerLoginInfo: function () {
            JsManager.StartProcessBar();
            var jsonParam = '';
            var serviceUrl = "get-site-login-customer-info";
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    let data = jsonData.data;
                    if (data.full_name)
                        $("#full_name").val(data.full_name).attr('readonly', true);
                    // if (data.email)
                    //     $("#email").val(data.email).attr('readonly', true);
                    if (data.phone_no)
                        $("#phone_no").val(data.phone_no).attr('readonly', true);
                    // initTelephone.setNumber(data.phone_no);
                    if (data.state)
                        $("#state").val(data.state).attr('readonly', true);
                    if (data.city)
                        $("#city").val(data.city).attr('readonly', true);
                    if (data.postal_code)
                        $("#postal_code").val(data.postal_code).attr('readonly', true);
                    if (data.street_address)
                        $("#street_address").val(data.street_address).attr('readonly', true);
                    if (data.street_address)
                        $("#street_address").val(data.street_address).attr('readonly', true);
                }
                JsManager.EndProcessBar();
            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
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
            SiteManager.DrawServiceTable();
            $("#tbl-service-cart").removeClass('d-none');
            return bookingList;
        },
        RemoveBookingSchedule: function (ind) {
            if (bookingList[ind] != undefined) {
                bookingList = bookingList.filter(function (item, index) {
                    return index != ind;
                });
            }

            SiteManager.DrawServiceTable();
            return bookingList;

        },
        DrawServiceTable: function () {
            $('#iSelectedServiceList').empty();
            $.each(bookingList, function (ind, item) {
                var $delItem = $('<i class="fa fa-trash text-danger cursor-pointer"></i>');
                $delItem.on("click", function () {
                    SiteManager.RemoveBookingSchedule(ind);
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
            })
        },
        CalculateServiceSummary: function () {
            $("#divServiceSection").empty();
            subtotal = 0;
            $.each(bookingList, function (i, v) {
                subtotal = parseFloat(parseFloat(subtotal) + parseFloat(v.employee_rate), 0);
                currency = v.currency;
                let servicehtml = '<div class="service-item">'
                    + '<div class="w-70 float-start">'
                    + '<div class="w-100 text-start">' + v.service_name + '</div>'
                    + '<div class="w-100 text-start" style="font-size:11px">Date:' + v.serviceDate + ' Time:' + v.serviceTime + '</div>'
                    + '</div>'
                    + '<div class="float-end">' + v.currency + v.employee_rate.toFixed(2) + '</div>'
                    + '</div>';
                $("#divServiceSection").append(servicehtml);
            });
            $("#divServiceSection").append('<div class="service-border-button"></div>');
            $("#summary-subtotal").text(currency + subtotal.toFixed(2));
            $("#summary-total").text(currency + subtotal.toFixed(2));
        },
        is_phone_verified: function () {
            JsManager.StartProcessBar();
            var jsonParam = { phone: $("#phone_no").val(), full_name: $("#full_name").val() };
            var serviceUrl = "is-phone-verified";
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                if (jsonData.redirect) {
                    window.location.href = jsonData.redirect;
                    return;
                }
                if (jsonData.isphoneVerified) {
                    $("#verified").css("display", "block");
                    $("#not-verified").css("display", "none");
                    $("#verification_status").val(true);
                } else {
                    $("#not-verified").css("display", "block");
                    $("#verified").css("display", "none");
                    $("#verification_status").val(false);
                }
                JsManager.EndProcessBar();
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        sendOtp: function () {
            var jsonParam = { phone: $("#phone_no").val() };
            var serviceUrl = "send-guest-otp";
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        verify_Phone: function () {
            JsManager.StartProcessBar();
            var jsonParam = { phone: $("#phone_no").val(), code: $("#code").val() };
            var serviceUrl = "verify-guest-otp";
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                if (jsonData.status == 1) {
                    $('#message').html(jsonData.message).removeClass('alert alert-danger')
                        .addClass('alert alert-success').fadeIn('slow');
                    $("#verified").css("display", "block");
                    $("#not-verified").css("display", "none");
                    $("#verification_status").val(true);
                }
                else {
                    console.log('wrong code');
                    $("#code").addClass('border-red');
                    $('#codeError').removeClass('d-none');
                }
                JsManager.EndProcessBar();
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        resend_otp: function () {
            JsManager.StartProcessBar();
            var jsonParam = { phone: $("#phone_no").val(), code: $("#code").val() };
            var serviceUrl = "resend-guest-otp";
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                if (jsonData.status == 1) {
                    $('#message').html(jsonData.message).removeClass('alert alert-danger')
                        .addClass('alert alert-success').fadeIn('slow');
                } else {
                    $('#message').html(jsonData.message).removeClass('alert alert-success')
                        .addClass('alert alert-danger').fadeIn('slow');
                }
                JsManager.EndProcessBar();
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        }
    };
})(jQuery);