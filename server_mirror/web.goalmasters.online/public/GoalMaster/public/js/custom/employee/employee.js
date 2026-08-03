var cal = null;
(function ($) {
    "use strict";
    var dTable = null;
    var calScheduleData = null;
    var selectedCalendarYear = null;
    var initTelephone;
    var cmn_branch_id;

    $(document).ready(function () {
        initTelephone = window.intlTelInput(document.querySelector("#contact_no"), {
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
            hiddenInput: "contact_no1",
            initialCountry: "auto",
            nationalMode: true,
            placeholderNumberType: "MOBILE",
            separateDialCode: true,
            utilsScript: "js/lib/tel-input/js/utils.js",
        });

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

        // $('.break_start_time').datetimepicker({
        //     datepicker: false,
        //     format: timeFormat,
        //     step: 5,
        //     onShow: function (ct, el) {
        //         this.setOptions({
        //             maxTime: $(el).parent().parent().find('.break_end_time').val() ? $(el).parent().parent('tr').find('.break_end_time').val() : false
        //         })
        //     }
        // });
        // $('.break_end_time').datetimepicker({
        //     datepicker: false,
        //     format: timeFormat,
        //     step: 5,
        //     onShow: function (ct, el) {
        //         this.setOptions({
        //             minTime: $(el).parent().parent().find('.break_start_time').val() ? $(el).parent().parent('tr').find('.break_start_time').val() : false
        //         })
        //     }
        // });

        cal = new tui.Calendar('#calendar', {
            defaultView: 'month',
            useCreationPopup: false,
            useDetailPopup: false
        });
        initTuiCalendarComponent();

        cal.on({
            clickSchedule: function (e) {
                $("#frmViewCalendarModal").modal('show');
                calScheduleData = e;
                var dateFrom = JsManager.DateFormatDefault(e.schedule.start._date)
                var dateTo = JsManager.DateFormatDefault(e.schedule.end._date)
                $("#divScheduleDetails").empty();
                $("#divScheduleDetails").append('<div class="w100 p-2"><b>Date From: </b> ' + dateFrom + ' <b>To : </b>' + dateTo + '</div><div class="w100 p-2  mt--2"><b>Details: </b>' + e.schedule.title + '</div>');
            },
            beforeCreateSchedule: function (e) {
                var dateFrom = JsManager.DateFormatDefault(e.start._date)
                var dateTo = JsManager.DateFormatDefault(e.end._date)
                $("#frmAddCalendarModal").modal('show');
                $("#holiday-title").val(e.title);
                $("#start-date").val(dateFrom);
                $("#end-date").val(dateTo);
                calScheduleData = e;
                e.guide.clearGuideElement();
            },
            beforeUpdateSchedule: function (e) {
                e.schedule.start = e.start;
                e.schedule.end = e.end;
                Manager.UpdateEmployeeOffDayByMove(e);
            },
            beforeDeleteSchedule: function (e) {
            }

        });

        $("#nav-offday-tab").on("click", function () {
            setTimeout(() => {
                $('.move-today').trigger('click');
                selectedCalendarYear = $("#renderRange").text().substring(0, 4);
                Manager.GetEmployeeOffDay(selectedCalendarYear);
            }, 400);
        });

        $("#btn-calendar-edit").on("click", function () {
            var sch = calScheduleData.schedule;
            $("#frmViewCalendarModal").modal('hide');
            $("#start-date").val(JsManager.DateFormatDefault(sch.start._date));
            $("#end-date").val(JsManager.DateFormatDefault(sch.end._date));
            $("#holiday-title").val(sch.title);
            $("#calId").val(sch.id);
            $("#frmAddCalendarModal").modal('show');
        });

        $("#btn-calendar-delete").on("click", function () {
            var sch = calScheduleData.schedule;
            Manager.DeleteEmployeeOffDay(sch);
            $("#frmViewCalendarModal").modal('hide');
        });

        $(".btn-move-calendar").on("click", function () {
            setTimeout(() => {
                let year = $("#renderRange").text().substring(0, 4);
                if (year != selectedCalendarYear) {
                    cal.clear();
                    Manager.GetEmployeeOffDay(year);
                    selectedCalendarYear = year;
                }
            }, 200);

        });

        //load department dropdown
        Manager.LoadDepartmentDropDown();
        //load designation dropdown
        Manager.LoadDesignationDropDown();
        //load branch dropdown
        Manager.LoadBranchDropDown();
        //load system user
        Manager.LoadSystemUserDropDown();

        //load employee services
        Manager.GetEmployeeServices('','');


        //save or update offday
        JsManager.JqBootstrapValidation('#inputFormOffDay', (form, event) => {
            event.preventDefault();
            if ($("#id").val() == "" || $("#id").val() == null) {
                event.preventDefault();
                Message.Warning("You need to save employee/staff first.");
            } else {
                Manager.SaveOrUpdateOffDay(form);
            }
        });

        //save or update employee
        $("#btnSaveEmployee").on("click", function (e) {
            e.preventDefault();
            var inputElements = [].slice.call(document.getElementsByClassName('cls-service-id'));
            var serviceCheckedValue = inputElements.filter(chk => chk.checked).length;

            if (!$("#cmn_branch_id").val()) {
                Message.Warning("Brnach is required");
            }
            else if (!$("#full_name").val()) {
                Message.Warning("Full Name is required");
            }
            else if (!$("#email_address").val()) {
                Message.Warning("Email is required");
            }
            else if (!$("#hrm_designation_id").val()) {
                Message.Warning("Designation is required");
            }
            else if (serviceCheckedValue == 0) {
                Message.Warning("Check minimum one service under Available Service tab.");
            }
            // else if (!$('.end_time').val() || !$('.end_time').val() || !$('.break_start_time').val() || !$('.break_end_time').val()) {
                else if (!$('.end_time').val() || !$('.end_time').val() ) {
                Message.Warning("Enter service time under Service Time tab.");
            }
            
            else {
                var formData = new FormData(document.querySelector('#inputForm'));
                formData.append("contact_no", $("#contact_no").val());
                if ($('#id').val() == null || $('#id').val() == '') {
                    Manager.Save(formData);
                } else {
                    Manager.Update(formData);
                }
            }
        });

        //add  modal
        $("#btnAdd").on("click", function () {
            Manager.GetEmployeeServices('','');
            Manager.ResetForm();
            $("#frmModal").modal('show');
        });

        $("#cmn_branch_id").on("change", function () {
            Manager.GetEmployeeServices('',$(this).val());
        });

        //load datatable
        Manager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        $("#pay_commission_based_on").on("change", function () {
            if ($(this).val() == 2) {
                $("#target_service_amount").removeAttr('readonly');
            }else{
                $("#target_service_amount").attr('readonly','readonly');
            }
        });
    });


    //show edit info modal
    $(document).on('click', '.dTableEdit', function () {
        var rowData = dTable.row($(this).parent()).data();
        Manager.GetEmployeeServices(rowData.id,rowData.cmn_branch_id);
        $("#id").val(rowData.id);
        $('#full_name').val(rowData.full_name);
        $('#empimagepreview').attr("src", JsManager.BaseUrl() + '/' + rowData.image_url);
        $('#empidcardimageview').attr("src", JsManager.BaseUrl() + '/' + rowData.id_card);
        $('#emppassportimageview').attr("src", JsManager.BaseUrl() + '/' + rowData.passport);
        $('#employee_id').val(rowData.employee_id);
        $('#cmn_branch_id').val(rowData.cmn_branch_id);
        $('#full_name').val(rowData.full_name);
        $('#email_address').val(rowData.email_address);
        initTelephone.setNumber('+' + rowData.contact_no);
        $('#present_address').val(rowData.present_address);
        $('#permanent_address').val(rowData.permanent_address);
        $('#gender').val(rowData.gender);
        $('#dob').val(rowData.dob);
        $('#hrm_department_id').val(rowData.hrm_department_id);
        $('#hrm_designation_id').val(rowData.hrm_designation_id);
        $('#specialist').val(rowData.specialist);
        $('#note').val(rowData.note);
        $('#status').val(rowData.status);
        $('#commission').val(rowData.commission);
        $('#pay_commission_based_on').val(rowData.pay_commission_based_on);
        $('#target_service_amount').val(rowData.target_service_amount);
        $('#salary').val(rowData.salary);
        Manager.PopulateEmployeeScheduleData(rowData.id);
        $("#frmModal").modal('show');
    });



    //photo preview
    $(document).on('change', '#image_url', function () {
        var output = document.getElementById('empimagepreview');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src)
        }
    });

    //id card preview
    $(document).on('change', '#id_card', function () {
        var output = document.getElementById('empidcardimageview');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src)
        }
    });

    //id card preview
    $(document).on('change', '#passport', function () {
        var output = document.getElementById('emppassportimageview');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src)
        }
    });


    $(document).on('hide.bs.modal', '#frmAddCalendarModal', function () {
        $('#calId').val('');
    });

    $(document).on('click', '.cls-category', function () {
        var val = $(this).prop("checked");
        $(this).parents('li').find('.cls-service-id').prop('checked', val)
    });




    var Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
            $('#empimagepreview').attr("src", "");
            $('#empidcardimageview').attr("src", "");
            $('#emppassportimageview').attr("src", "");
            $("#id").val('');
        },

        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "employee-store";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        $("#id").val(jsonData.data.employee_id);
                        Manager.GetDataList(1); //reload datatable
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

        Update: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "employee-update";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        Manager.GetDataList(1); //reload datatable
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

        LoadDepartmentDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-department";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#hrm_department_id", jsonData.data, "Select Department", '');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadDesignationDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-designation";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#hrm_designation_id", jsonData.data, "اخترة حجز", '');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadBranchDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-branch-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#cmn_branch_id", jsonData.data, "اختر ادارة", '');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadSystemUserDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-system-user-list";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#user_id", jsonData.data, "Select System User", '');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        UpdateEmployeeOffDayByMove: function (schEvent) {

            JsManager.StartProcessBar();
            var jsonParam = {
                id: schEvent.schedule.id,
                start_date: JsManager.DateFormatDefault(schEvent.schedule.start._date),
                end_date: JsManager.DateFormatDefault(schEvent.schedule.end._date),
                title: schEvent.schedule.title,
            };
            var serviceUrl = "update-employee-offday-by-move";
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    Message.Success("Move successfully");
                    cal.updateSchedule(schEvent.schedule.id, schEvent.schedule.calendarId, schEvent.schedule);
                } else {
                    Message.Error("save");
                }
                JsManager.EndProcessBar();

            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }

        },

        SaveOrUpdateOffDay: function (form) {
            if (Message.Prompt()) {
                if ($("#calId").val() == "wh") {
                    Message.Warning('You are not allow to update this schedule.');
                    return false;
                } else {
                    JsManager.StartProcessBar();
                    var jsonParam = form.serialize() + "&sch_employee_id=" + $("#id").val();
                    var serviceUrl = "save-update-employee-offday";
                    JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                    function onSuccess(jsonData) {
                        if (jsonData.status == "1") {
                            Message.Success("save");
                            var sch = {
                                id: jsonData.data.id,
                                title: jsonData.data.title,
                                isAllDay: true,
                                start: jsonData.data.start_date,
                                end: jsonData.data.end_date,
                                category: 'allday',
                                bgColor: '#f77c1f',
                                color: '#fff'
                            };
                            if ($("#calId").val() != "") {
                                cal.updateSchedule(calScheduleData.schedule.id, calScheduleData.schedule.calendarId, sch);
                                $("#calId").val('');
                            } else {
                                cal.createSchedules([sch]);
                                $("#calId").val('');
                            }
                            $("#frmAddCalendarModal").modal('hide');
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
        },

        GetEmployeeOffDay: function (calYear) {
            JsManager.StartProcessBar();
            var jsonParam = {
                sch_employee_id: $("#id").val(),
                cmn_branch_id: $("#cmn_branch_id").val(),
                year: calYear
            };
            var serviceUrl = "get-employee-offday-list";
            JsManager.SendJson("GET", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                cal.clear();
                if (jsonData.status == "1") {
                    if (jsonData.data.employeeOffday.length > 0) {
                        let arrEmpOffday = [];
                        $.each(jsonData.data.employeeOffday, function (i, v) {
                            let sch = {
                                id: v.id,
                                start: v.start,
                                end: v.end,
                                title: v.title,
                                isAllDay: true,
                                category: 'allday',
                                bgColor: '#f77c1f',
                                color: '#fff'
                            }
                            arrEmpOffday.push(sch);
                        });

                        cal.createSchedules(arrEmpOffday);
                    }
                    if (jsonData.data.weeklyHoliday.length > 0) {
                        let arrWeeklyHoliday = [];
                        $.each(jsonData.data.weeklyHoliday, function (i, v) {
                            let sch = {
                                id: v.id,
                                start: v.start,
                                end: v.end,
                                title: v.title,
                                isAllDay: true,
                                category: 'allday',
                                bgColor: 'red',
                                color: '#fff',
                                isReadOnly: true,
                            }
                            arrWeeklyHoliday.push(sch);
                        });
                        cal.createSchedules(arrWeeklyHoliday);
                    }
                    if (jsonData.data.businessHoliday.length > 0) {
                        let arrBusinessHoliday = [];
                        $.each(jsonData.data.businessHoliday, function (i, v) {
                            let sch = {
                                id: 'wh',
                                start: v.start,
                                end: v.end,
                                title: v.title,
                                isAllDay: true,
                                category: 'allday',
                                bgColor: '#ff4343',
                                color: '#fff',
                                isReadOnly: true,
                            }
                            arrBusinessHoliday.push(sch);
                        });
                        cal.createSchedules(arrBusinessHoliday);
                    }
                }
                JsManager.EndProcessBar();

            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }

        },

        DeleteEmployeeOffDay: function (sch) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: sch.id };
                var serviceUrl = "delete-employee-offday";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        cal.deleteSchedule(sch.id, sch.calendarId);
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

        GetEmployeeServices: function (empid,branchId) {
            var jsonParam = { sch_employee_id: empid, branch :branchId};
            var serviceUrl = "get-employee-services";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {

                var filteredCategories = jsonData.data.filter(function (category) {
                    return category.id == branchId; // Assuming 'branch_id' is a property of the category
                });

                console.log('aaaaaaa',jsonData);

                if (jsonData.status == 1) {
                    $("#ul-employee-service").empty();
                    var html = "";
                    let loopCount = 0;
                    $.each(jsonData.data, function (i, v) {
                        let services = "";
                        $.each(v.service, function (si, sv) {
                            var serviceStatus = '';
                            if (sv.status == 1)
                                serviceStatus = "checked";
                            services += '<li>' +
                                '<div class="div-category-service row">' +
                                '<div class="float-left w70">' +
                                '<div class="float-left mr-2">' +
                                '<input type="checkbox" name="service[' + loopCount + '][sch_service_id]" value=' + sv.id + ' ' + serviceStatus + ' class="cls-service-id" />' +
                                '<input type="hidden" value=' + sv.emp_service_id + ' name="service[' + loopCount + '][emp_service_id]" class="cls-emp-service-id"/>' +
                                '</div>' +
                                '<div class="float-left">' +
                                sv.title +
                                '</div>' +
                                '</div>' +
                                '<div class="float-left w30">' +
                                '<input type="number" id="fee" name="service[' + loopCount + '][fees]" value=' + sv.fees + ' class="cls-service-fee form-control input-full text-right" />' +
                                '</div>' +
                                '</div>' +
                                '</li>';
                            loopCount++;
                        });

                        html += '<li>' +
                            '<div class="div-service-category row">' +
                            '<div class="float-left w70">' +
                            '<div class="float-left mr-2">' +
                            '<input type="checkbox" class="cls-category" />' +
                            '</div>' +
                            '<div class="float-left">'
                            + v.name +
                            '</div>' +
                            '</div>' +
                            '<div class="float-left w30 text-center">السعر</div>' +
                            '</div>' +
                            '<ul>'
                            + services +
                            '</ul>' +
                            '</li>';
                    });
                    $("#ul-employee-service").append(html);

                }
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },


        PopulateEmployeeScheduleData: function (employeeId) {

            var jsonParam = { employeeId: employeeId };
            var serviceUrl = 'get-employee-schedule';
            JsManager.SendJson("GET", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                $.each($("#tblEmployeeSchedule tr"), function (tri, trv) {
                    if (tri > 0) {
                        $.each(jsonData.data, function (di, dv) {
                            if ($(trv).find('.day').val() == dv.day) {
                                $(trv).find(".id").val(dv.id);
                                $(trv).find(".start_time").val(dv.start_time);
                                $(trv).find(".end_time").val(dv.end_time);
                                // $(trv).find(".break_start_time").val(dv.break_start_time);
                                // $(trv).find(".break_end_time").val(dv.break_end_time);
                                if (dv.is_off_day == 1) {
                                    $(trv).find(".is_off_day").prop("checked", true);
                                } else {
                                    $(trv).find(".is_off_day").prop("checked", false);
                                }
                            }
                        });
                    }
                });
            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }
        },

        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "get-employee";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                Manager.LoadDataTable(jsonData.data, refresh);

            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadDataTable: function (data, refresh) {
            if (refresh == "0") {
                dTable = $('#tableElement').DataTable({
                    dom: "<'row'<'col-md-6'B><'col-md-3'l><'col-md-3'f>>" + "<'row'<'col-md-12'tr>>" + "<'row'<'col-md-5'i><'col-md-7 mt-7'p>>",
                    initComplete: function () {
                        dTableManager.Border(this, 350);
                        $(".dTableDelete").hide();
                    },
                    buttons: [
                        {
                            text: '<i class="fa fa-file-pdf"></i> PDF',
                            className: 'btn btn-sm',
                            extend: 'pdfHtml5',
                            exportOptions: {
                                columns: [2, 3, 4, 5, 6]
                            },
                            title: 'Customer List'
                        },
                        {
                            text: '<i class="fa fa-print"></i> Print',
                            className: 'btn btn-sm',
                            extend: 'print',
                            exportOptions: {
                                columns: [2, 3, 4, 5, 6]
                            },
                            title: 'Customer List'
                        },
                        {
                            text: '<i class="fa fa-file-excel"></i> Excel',
                            className: 'btn btn-sm',
                            extend: 'excelHtml5',
                            exportOptions: {
                                columns: [2, 3, 4, 5, 6]
                            },
                            title: 'Customer List'
                        }
                    ],

                    scrollY: "350px",
                    scrollX: true,
                    scrollCollapse: true,
                    lengthMenu: [[50, 100, 500, -1], [50, 100, 500, "All"]],
                    columnDefs: [
                        { visible: false, targets: [] },
                        { "className": "dt-center", "targets": [3] }
                    ],
                    columns: [
                        {
                            data: null,
                            name: '',
                            'orderable': false,
                            'searchable': false,
                            title: '#SL',
                            width: 8,
                            render: function () {
                                return '';
                            }
                        },
                        {
                            name: 'Option',
                            title: 'Option',
                            width: 60,
                            render: function (data, type, row) {
                                return EventManager.DataTableCommonButton();
                            }
                        },
                        {
                            data: 'image_url',
                            name: 'image_url',
                            title: 'Image',
                            render: function (data, type, row) {
                                return '<img width="120" height="86" src="' + JsManager.BaseUrl() + '/' + data + '" />';
                            }
                        },
                        {
                            data: 'full_name',
                            name: 'full_name',
                            title: 'Staff Name'
                        },
                        {
                            data: 'branch',
                            name: 'branch',
                            title: 'Branch'
                        },
                        {
                            data: 'email_address',
                            name: 'email_address',
                            title: 'Email'
                        },
                        {
                            data: 'contact_no',
                            name: 'contact_no',
                            title: 'Phone Number'
                        },
                        {
                            data: 'dob',
                            name: 'dob',
                            title: 'Date of Birth'
                        },
                        {
                            data: 'status',
                            name: 'status',
                            title: 'Status',
                            render: function (data, type, row) {
                                if (data == 1) {
                                    return "Public";
                                } else if (data == 2) {
                                    return "Private";
                                } else if (data == 3) {
                                    return "Disable";
                                }
                            }
                        }
                    ],
                    fixedColumns: false,
                    data: data
                });
            } else {
                dTable.clear().rows.add(data).draw();
                $(".dTableDelete").hide();
            }
        }


    };

})(jQuery);
