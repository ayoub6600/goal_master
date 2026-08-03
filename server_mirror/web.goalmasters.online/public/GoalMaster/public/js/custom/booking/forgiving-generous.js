(function ($) {
    "use strict";

    var dTable = null;
    var _id = null;

    $(document).ready(function () {
        Manager.GetDataList(0);

        dTableManager.dTableSerialNumber(dTable);

        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            if (_id == null) {
                Manager.Save(form);
            } else {
                Manager.Update(form, _id);
            }
        });
    });

    var Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
        },

 GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "get-forgiving-generous?charset=utf8";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                Manager.LoadDataTable(jsonData.data, refresh);
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadDataTable: function (data, refresh) {
            console.log(data);
            
            if (refresh == "0") {
                dTable = $('#tableElement').DataTable({
                    dom: "<'row'<'col-md-6'B><'col-md-3'l><'col-md-3'f>>" +
                         "<'row'<'col-md-12'tr>>" +
                         "<'row'<'col-md-5'i><'col-md-7 mt-7'p>>",
                    
                    buttons: [
                        {
                            extend: 'copyHtml5',
                            text: '<i class="fas fa-copy"></i> نسخ',
                            className: 'btn btn-info',
                            filename: 'Forgiving Generous Report',
                        },
                        {
                            extend: 'csvHtml5',
                            text: '<i class="fas fa-file-csv"></i> CSV',
                            className: 'btn btn-primary',
                            filename: 'Forgiving Generous Report',
                        },
                        {
                            extend: 'excelHtml5',
                            text: '<i class="fas fa-file-excel"></i> Excel',
                            className: 'btn btn-success',
                            filename: 'Forgiving Generous Report',
                        },
                        {
                            extend: 'pdfHtml5',
                            text: '<i class="fas fa-file-pdf"></i> PDF',
                            className: 'btn btn-danger',
                            filename: 'Forgiving Generous Report',
                        }
                    ],

                    language: {
                        url: "//cdn.datatables.net/plug-ins/1.11.5/i18n/Arabic.json",
                        encoding: "UTF-8"
                    },
                    

                    initComplete: function () {
                        dTableManager.Border(this, 350);
                    },
                    
                    scrollY: "350px",
                    scrollX: true,
                    scrollCollapse: true,
                    lengthMenu: [[50, 100, 500, -1], [50, 100, 500, "الكل"]],
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
                            title: '#',
                            width: 8,
                            render: function () {
                                return '';
                            }
                        },
                        {
                            data: 'id',
                            name: 'id',
                            title: 'رقم'
                        },
                        {
                            data: 'booking.customer.full_name',
                            name: 'customer_full_name',
                            title: 'اسم العميل',
                        },
                        {
                            data: 'booking.customer.phone_no',
                            name: 'customer_phone_no',
                            title: 'رقم الهاتف',
                        },
                         {
                            data: 'booking.branch.name',
                            name: 'branch_name',
                            title: 'الملعب',
                        },
                        {
                            data: 'booking.service.title',
                            name: 'service_title',
                            title: 'نوع الحجز',
                        },
                        {
                            data: 'booking.service.category.name',
                            name: 'service_category_name',
                            title: 'نوع الرياضة',
                        },
                        {
                            data: 'date',
                            name: 'date',
                            title: 'ميعاد الحجز',
                            render: function (data, type, row) {
                                if (row.booking && row.booking.date) {
                                    return moment(row.booking.date).format('MMM DD, YYYY');
                                }
                                return ''; 
                            }
                        },
                        
                        {
                            data: 'start_time',
                            name: 'start_time',
                            title: 'وقت البدء',
                            render: function (data, type, row) {
                                if (row.booking && row.booking.start_time && row.booking.end_time) {
                                    return moment(row.booking.start_time, 'HH:mm:ss').format('hh:mm A') + ' - ' + moment(row.booking.end_time, 'HH:mm:ss').format('hh:mm A');
                                }
                                return '';
                            }
                        },
                        
                        
                        {
                            data: 'allowed_amount',
                            name: 'allowed_amount',
                            title: 'مبلغ المسامحه',
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
