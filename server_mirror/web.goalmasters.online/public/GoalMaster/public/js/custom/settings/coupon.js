(function ($) {
    "use strict";

    var dTable = null;
    var _id = null;
    $(document).ready(function () {

        //load datatable
        Manager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        //add  modal
        $("#btnAdd").on("click",function () {
            _id = null;
            Manager.ResetForm();
            $("#frmModal").modal('show');
        });

        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            event.stopPropagation();
            if (_id == null) {
                Manager.Save(form);
            } else {
                Manager.Update(form, _id);
            }
        });

    });

    //show edit info modal
    $(document).on('click', '.dTableEdit', function () {
        var rowData = dTable.row($(this).parent()).data();
        _id = rowData.id;
        $('#code').val(rowData.code);
        $('#start_date').val(rowData.start_date_input);
        $('#end_date').val(rowData.end_date_input);
        $('#percent').val(rowData.percent);
        $('#coupon_type').val(rowData.coupon_type);
        $('#customer_id').val(rowData.user_id);
        $('#min_order_value').val(rowData.min_order_value);
        $('#max_discount_value').val(rowData.max_discount_value);
        $('#is_fixed').val(rowData.is_fixed);
        $('#use_limit').val(rowData.use_limit);
        $('#status').val(rowData.status);

        $("#frmModal").modal('show');
    });


    //delete
    $(document).on('click', '.dTableDelete', function () {
        var rowData = dTable.row($(this).parent()).data();
        Manager.Delete(rowData.id);
    });


    var Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
        },
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "coupon-save";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        Manager.ResetForm();
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
        Update: function (form, id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "coupon-update/"+id;
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        _id = null;
                        $("#frmModal").modal('hide');
                        Manager.ResetForm();
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
        Delete: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: id };
                var serviceUrl = "coupon-delete/"+id;
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        Manager.GetDataList(1); //reload datatable
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
        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "get-coupons";
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
                    },
                    buttons: [
                        {
                            text: '<i class="fa fa-file-pdf"></i> PDF',
                            className: 'btn btn-sm',
                            extend: 'pdfHtml5',
                            exportOptions: {
                                columns: [2,5,6,7,8,10,11,12]
                            },
                            title: 'Coupon List'
                        },
                        {
                            text: '<i class="fa fa-print"></i> Print',
                            className: 'btn btn-sm',
                            extend: 'print',
                            exportOptions: {
                                columns: [2,5,6,7,8,10,11,12]
                            },
                            title: 'Coupon List'
                        },
                        {
                            text: '<i class="fa fa-file-excel"></i> Excel',
                            className: 'btn btn-sm',
                            extend: 'excelHtml5',
                            exportOptions: {
                                columns: [2,5,6,7,8,10,11,12]
                            },
                            title: 'Coupon List'
                        }
                    ],

                    scrollY: "350px",
                    scrollX: true,
                    scrollCollapse: true,
                    lengthMenu: [[50, 100, 500, -1], [50, 100, 500, "All"]],
                    columnDefs: [
                        { visible: false, targets: [3,4,9] },
                        { orderable: false, searchable: false, targets: [0,1] },
                        { "className": "dt-center", "targets": [3] }
                    ],
                    columns: [
                        {
                            data: null,
                            name: '',
                            title: '#SL',
                            orderable: false, searchable: false,
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
                            data: 'code',
                            name: 'code',
                            title: 'Code'
                        },
                        {
                            data: 'start_date_input',
                            name: 'start_date_input',
                            title: 'Start Date'
                        },
                        {
                            data: 'end_date_input',
                            name: 'end_date_input',
                            title: 'End Date'
                        },
                        {
                            data: 'start_date_show',
                            name: 'start_date_show',
                            title: 'Start Date'
                        },
                        {
                            data: 'end_date_show',
                            name: 'end_date_show',
                            title: 'End Date'
                        },
                        {
                            data: 'percent',
                            name: 'percent',
                            title: 'Value'
                        },
                        {
                            data: 'coupon_type',
                            name: 'coupon_type',
                            title: 'Coupon For',
                            render : function(data, type, row){
                                return (data == 1) ? 'All User' : 'Single User';
                            }
                        },
                        {
                            data: 'user_id',
                            name: 'user_id',
                        },                        
                        {
                            data: 'customer',
                            name: 'customer',
                            title: 'Customer',
                            render : function(data, type, row){
                                return (data) ? data.full_name : '';
                            }
                        },
                        {
                            data: 'use_limit',
                            name: 'use_limit',
                            title: 'Use Limit'
                        },
                        {
                            data: 'status',
                            name: 'status',
                            title: 'Status',
                            render : function(data, type, row){
                                return (data) ? 'Enable' : 'Disable';
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