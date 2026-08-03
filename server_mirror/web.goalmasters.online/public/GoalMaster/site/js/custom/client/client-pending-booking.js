
var PendingBooking
function cancelBooking(bookingId) {
    PendingBooking.CancelBooking(bookingId);
}


function payDueBookingAmount(bookingId) {
    window.location = 'choose-payment-method?bookingId=' + bookingId;
}

(function ($) {
    "use strict";
    var dTable;
    $(document).ready(function () {
        PendingBooking.GetDataList(0);
    });

    PendingBooking = {
        PayDueBookingAmount: function (bookingId) {
            JsManager.StartProcessBar();
            var jsonParam = { id: bookingId };
            var serviceUrl = 'site-make-online-due-payment';
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    if (jsonData.data.paypalReturnUrl.status = 201) {
                        window.location.href = jsonData.data.paypalReturnUrl.data.links[1].href;
                    } else {
                        //order will be cancel by redirect
                        SiteManager.CancelBooking(jsonData.data.paypalReturnUrl.purchase_units[0].reference_id)
                    }
                } else {
                    Message.Error("payment failed");
                }
                JsManager.EndProcessBar();

            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }
        },
        CancelBooking: function (bookingId) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { bookingId: bookingId };
                var serviceUrl = 'client-dashboard-available-cancel-booking';
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("cancel");
                        PendingBooking.GetDataList(1);
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
        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "get-client-pending-booking-list";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                PendingBooking.LoadDataTable(jsonData.data, refresh);
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadDataTable: function (data, refresh) {
            if (refresh == "0") {
                dTable = $('#tableElement').DataTable({
                    dom: "<'row'<'col-md-12'tr>>" + "<'row'<'col-md-5'i><'col-md-7 mt-7'p>>",
                    buttons: [],
                    // scrollY: "350px",
                    // scrollX: true,
                    scrollY: true,
                    scrollCollapse: true,
                    lengthMenu: [[5, 100, 500, -1], [5, 100, 500, "All"]],
                    columnDefs: [
                        { visible: false, targets: [] },
                        { "className": "dt-center", "targets": [] }
                    ],
                    order: [[2, 'desc']],
                    columns: [
                        {
                            data: 'service',
                            name: 'service',
                            title: 'Service Information',
                            width: 500,
                            render: function (data, type, row) {
                                return '<div class="flex-1 ml-3 pt-1">' +
                                    '<h6 class="fw-bold mb-1">' +
                                    "No# " + row['id'] + " | " + row['service'] +
                                    '<span class="' + PendingBooking.ServiceFontColorClass(row['status']) + ' pl-3"> ' + PendingBooking.ServiceStatus(row['status']) + '</span>' +
                                    '</h6>' +
                                    '<span class="text-muted">' +
                                    row['branch'] + " | " + row['employee'] + " | <span class='text-primary'>" + moment(row['date'] + ' ' + row['start_time']).format('LT') + " إلى " + moment(row['date'] + ' ' + row['end_time']).format('LT') + "</span><br/>" +
                                    "Due# <span class='text-danger'>" + parseFloat(row['due']).toFixed(2) + "</span> | " + (row['remarks'] == null ? "No remarks found!" : row['remarks'])
                                    + '</span>' +
                                    '</div>';
                            }
                        },
                        {
                            data: 'date',
                            name: 'date',
                            title: 'Date',
                            width: 100,
                            render: function (data, type, row) {
                                return moment(data).format('ll');
                            }
                        },
                        {
                            name: 'id',
                            data: 'id',
                            title: 'Option',
                            width: 60,
                            render: function (data, type, row) {
                                let disabled = '';
                                if (row['status'] == '4' || row['status'] == '3') {
                                    disabled = 'disabled';
                                }
                                let btn = "<button " + disabled + " onclick='cancelBooking(" + row['id'] + ")' class='btn btn-danger btn-sm cancel-padding fs-11 float-end'><i class='fa fa-times-circle' aria-hidden='true'></i> إلغاء</button>";
                                if (parseFloat(row['due']) <= 1)
                                    disabled = 'disabled';
                                btn = btn + "<br/><button " + disabled + " onclick='payDueBookingAmount(" + row['id'] + ")' class='btn btn-primary btn-sm cancel-padding fs-11 mt-1 float-end'>إدفع الآن</button>";
                                return btn;
                            }
                        }

                    ],
                    fixedColumns: false,
                    data: data
                });
            } else {
                dTable.clear().rows.add(data).draw();
            }
        },
        ServiceStatus: function (status) {
            var serviceStatus = ['غير خالص', 'بانتظار قبول الطلب', 'موافق عليه', 'إلغاء', 'خالص'];
            // var serviceStatus = ['Pending', 'Processing', 'Approved', 'Cancel', 'Done'];
            return serviceStatus[status];
        },

        ServiceStatusColor: function (status) {
            var serviceStatus = ['bg_pending', 'bg_processing', 'bg_approved', 'bg_cancel', 'bg_done'];
            return serviceStatus[status];
        },
        ServiceFontColorClass: function (status) {
            var serviceColor = ['fc_pending', 'fc_processing', 'fc_approved', 'fc_cancel', 'fc_done'];
            return serviceColor[status];
        },
    };
})(jQuery);