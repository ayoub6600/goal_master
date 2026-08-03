(function ($) {
    "use strict";
    var dTable;
    $(document).ready(function () {
        DoneBooking.GetDataList(0);
    });


    var DoneBooking = {

        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "get-done-pending-booking-list";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                DoneBooking.LoadDataTable(jsonData.data, refresh);
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
                    scrollY: true,
                    scrollCollapse: true,
                    lengthMenu: [[5, 100, 500, -1], [5, 100, 500, "All"]],
                    columnDefs: [
                        { visible: false, targets: [] },
                        { "className": "dt-center", "targets": [] }
                    ],
                    order: [[1, 'desc']],
                    columns: [
                        {
                            data: 'service',
                            name: 'service',
                            title: 'Service Information',
                            width: 600,
                            render: function (data, type, row) {
                                return '<div class="flex-1 ml-3 pt-1">' +
                                    '<h6 class="fw-bold mb-1">' +
                                    "No# " + row['id'] + " | " + row['service'] +
                                    '<span class="' + DoneBooking.ServiceFontColorClass(row['status']) + ' pl-3"> ' + DoneBooking.ServiceStatus(row['status']) + '</span>' +
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