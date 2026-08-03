(function ($) {
    "use strict";

    var dTable = null;
    var _id = null;

    $(document).ready(function () {

        //load datatable
        Manager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            if (_id == null) {
                Manager.Save(form);
            } else {
                Manager.Update(form, _id);
            }
        });

    });

    function formatDate(date,special_char) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;

        return [year, month, day].join(special_char);
    }

    //show edit info modal
    $(document).on('click', '.dTableEdit', function () {
        var rowData = dTable.row($(this).parent()).data();
        _id = rowData.id;

        // const is_monthly_active_input = $('#is_monthly_active');
        // is_monthly_active_input.val(rowData.is_monthly_active);
        // is_monthly_active_input.attr('checked', rowData.is_monthly_active === 1);
        const todayDate = moment(new Date(), 'YYYY-MM-DD');
        $('#divServiceDate').datetimepicker('destroy');
        Manager.ServiceDatePicker(todayDate);
        $("#serviceDate").val(formatDate(todayDate,'-'));

        $("#frmModal").modal('show');
    });


    var Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
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
                }
            });
        },
        Update: function (form, id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&id=" + id;
                var serviceUrl = "monthly-booking-update";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        _id = null;
                        Manager.ResetForm();
                        $("#frmModal").modal('hide');
                        Manager.GetDataList(1); //reload datatable
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
        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "get-monthly-booking";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                Manager.LoadDataTable(jsonData.data, refresh);
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadDataTable: function (data, refresh) {
            // console.log(data[0].customer.full_name);
            
            if (refresh == "0") {
                dTable = $('#tableElement').DataTable({
                    dom: "<'row'<'col-md-6'B><'col-md-3'l><'col-md-3'f>>" + "<'row'<'col-md-12'tr>>" + "<'row'<'col-md-5'i><'col-md-7 mt-7'p>>",
                    initComplete: function () {

                        dTableManager.Border(this, 350);

                    },
                    buttons: [
                        {
                            text: '<i class="fa fa-file-pdf"></i> PDF',
                            className: 'btn btn-sm',
                            extend: 'pdfHtml5',
                            exportOptions: {
                                columns: [2]
                            },
                            title: 'Category List'
                        },
                        {
                            text: '<i class="fa fa-print"></i> Print',
                            className: 'btn btn-sm',
                            extend: 'print',
                            exportOptions: {
                                columns: [2]
                            },
                            title: 'Category List'
                        },
                        {
                            text: '<i class="fa fa-file-excel"></i> Excel',
                            className: 'btn btn-sm',
                            extend: 'excelHtml5',
                            exportOptions: {
                                columns: [2]
                            },
                            title: 'Category List'
                        }
                    ],

                    scrollY: "350px",
                    scrollX: true,
                    scrollCollapse: true,
                    lengthMenu: [[50, 100, 500, -1], [50, 100, 500, "All"]],
                    columnDefs: [
                        { visible: false, targets: [] },
                        { "className": "dt-center", "targets": [] }
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
                            data: 'id',
                            name: 'id',
                            title: 'No#'
                        },
                        {
                            data: 'customer.full_name',
                            name: 'customer.full_name',
                            title: 'اسم العميل',
                            render: function (data, type, row) {
                                return data ? data : 'غير متوفر';
                            }
                        },        
                        {
                            data: 'branch_name',
                            name: 'branch_name',
                            title: 'اسم الملعب',
                            render: function (data, type, row) {
                                return data ? data : 'غير متوفر';
                            }
                        },
                        {
                            data: 'date',
                            name: 'date',
                            title: 'Date',
                            render: function (data, type, row) {
                                return moment(data).format('MMM DD, YYYY');
                            }
                        },
                        {
                            data: 'start_time',
                            name: 'start_time',
                            title: 'Start Time',
                            render: function (data, type, row) {
                                return data + ' - ' +  row['end_time'];
                                // return moment(data).format('hh:mm:ss') + ' - ' +  moment(row['end_time']).format('h:m:s');
                            }
                        },
                        {
                            data: 'service_bookings_all_count',
                            name: 'service_bookings_all_count',
                            title: 'Booking Count',
                            width:150,
                            render:function(data,type,row){
                                return '<span class="badge badge-success">'+data+'</span>'
                            }
                        },
                        {
                            data: 'is_monthly_active',
                            name: 'is_monthly_active',
                            title: 'Is Active',
                            width:150,
                            render:function(data,type,row){
                                return row['is_monthly_active'] === 1 ? '<span class="badge badge-success">'+'نشط'+'</span>' :  '<span class="badge badge-danger">'+'غير نشط'+'</span>'
                            }
                        },
                        {
                            name: 'Option',
                            title: 'Option',
                            width: 200,
                            render: function (data, type, row) {

                                return row['is_monthly_active'] === 1 ? '<button class="btn btn-primary btn-round float-left dTableEdit mr-2" title="Click to edit"><i class="fas fa-edit"></i> لإلغاء الحجز </button>' : '';
                            }
                        },

                    ],
                    fixedColumns: false,
                    data: data
                });
            } else {
                dTable.clear().rows.add(data).draw();
            }
        }
    };
})(jQuery);