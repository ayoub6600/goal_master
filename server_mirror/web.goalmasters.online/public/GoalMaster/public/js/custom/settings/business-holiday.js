var cal;
(function ($) {
    "use strict";
    var calScheduleData = null;
    var selectedCalendarYear = null;

    $(document).ready(function () {

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
                $("#title").val(e.title);
                $("#start-date").val(dateFrom);
                $("#end-date").val(dateTo);
                calScheduleData = e;
                e.guide.clearGuideElement();
            },
            beforeUpdateSchedule: function (e) {
                e.schedule.start = e.start;
                e.schedule.end = e.end;
                Manager.UpdateBusinessHolidayByMove(e);
            },
            beforeDeleteSchedule: function (e) {

            }

        });


        $("#btn-calendar-edit").on("click",function () {
            var sch = calScheduleData.schedule;
            $("#frmViewCalendarModal").modal('hide');
            $("#start-date").val(JsManager.DateFormatDefault(sch.start._date));
            $("#end-date").val(JsManager.DateFormatDefault(sch.end._date));
            $("#title").val(sch.title);
            $("#id").val(sch.id);
            $("#frmAddCalendarModal").modal('show');
        });

        $("#btn-calendar-delete").on("click",function () {
            var sch = calScheduleData.schedule;
            Manager.DeleteBusinessHoliday(sch);
            $("#frmViewCalendarModal").modal('hide');
        });

        $(".btn-move-calendar").on("click",function () {
            setTimeout(() => {
                let year = $("#renderRange").text().substring(0, 4);
                if (year != selectedCalendarYear) {
                    cal.clear();
                    Manager.GetBusinessHoliday(year);
                    selectedCalendarYear = year;
                }
            }, 200);

        });

        //save or update offday
        JsManager.JqBootstrapValidation('#inputFormCalendar', (form, event) => {
            event.preventDefault();
            Manager.SaveOrUpdateBusinessHoliday(form);
        });

        Manager.LoadBranchDropDown();

        setTimeout(() => {
            $('.move-today').trigger('click');
            selectedCalendarYear = $("#renderRange").text().substring(0, 4);
            Manager.GetBusinessHoliday(selectedCalendarYear);
        }, 400);

        $("#cmn_branch_id").on("click",function () {
            selectedCalendarYear = $("#renderRange").text().substring(0, 4);
            Manager.GetBusinessHoliday(selectedCalendarYear);
        });
    });


    $(document).on('hide.bs.modal', '#frmAddCalendarModal', function () {
        $('#id').val('');
    });





    var Manager = {

        UpdateBusinessHolidayByMove: function (schEvent) {

            JsManager.StartProcessBar();
            var jsonParam = {
                id: schEvent.schedule.id,
                start_date: JsManager.DateFormatDefault(schEvent.schedule.start._date),
                end_date: JsManager.DateFormatDefault(schEvent.schedule.end._date),
                title: schEvent.schedule.title
            };
            var serviceUrl = "update-business-holiday-by-move";
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
        SaveOrUpdateBusinessHoliday: function (form) {
            if (Message.Prompt()) {
                if ($("#id").val() == "wh") {
                    Message.Warning('You are not allow to update this schedule.');
                    return false;
                } else {
                    JsManager.StartProcessBar();
                    var jsonParam = form.serialize() + "&cmn_branch_id=" + $("#cmn_branch_id").val();
                    var serviceUrl = "save-update-business-holiday";
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
                            if ($("#id").val() != "") {
                                cal.updateSchedule(calScheduleData.schedule.id, calScheduleData.schedule.calendarId, sch);
                                $("#id").val('');
                            } else {
                                cal.createSchedules([sch]);
                                $("#id").val('');
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
        GetBusinessHoliday: function (calYear) {
            JsManager.StartProcessBar();
            var jsonParam = {
                cmn_branch_id: $("#cmn_branch_id").val(),
                year: calYear
            };
            var serviceUrl = "get-business-holiday";
            JsManager.SendJsonAsyncON("GET", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                cal.clear();
                if (jsonData.status == "1") {
                    if (jsonData.data.businessHoliday.length > 0) {
                        let arrBusinessHoliday = [];
                        $.each(jsonData.data.businessHoliday, function (i, v) {
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
                            arrBusinessHoliday.push(sch);
                        });

                        cal.createSchedules(arrBusinessHoliday);
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
                }
                JsManager.EndProcessBar();

            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }

        },

        DeleteBusinessHoliday: function (sch) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: sch.id };
                var serviceUrl = "delete-business-holiday";
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
    };

})(jQuery);
